from fastapi import FastAPI
import logging
from app.api.v1.api import api_router
from app.core.database import Base, engine

logger = logging.getLogger(__name__)

from fastapi.middleware.cors import CORSMiddleware

from contextlib import asynccontextmanager
from app.core.config import settings

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize Redis for caching and rate limiting on startup
    # try:
    #     from fastapi_cache import FastAPICache
    #     from fastapi_cache.backends.redis import RedisBackend
    #     from fastapi_limiter import FastAPILimiter
    #     from app.core.redis import get_redis_client
    #     
    #     # Use the unified redis client helper
    #     redis_client = get_redis_client()
    #     
    #     # Initialize Cache
    #     FastAPICache.init(RedisBackend(redis_client), prefix="fastapi-cache")
    #     logger.info("FastAPI Cache initialized successfully")
    #     
    #     # Initialize Rate Limiter
    #     try:
    #         await FastAPILimiter.init(redis_client)
    #         logger.info("FastAPI Limiter initialized successfully")
    #     except Exception as limiter_e:
    #         FastAPILimiter.redis = None
    #         FastAPILimiter.lua_sha = None
    #         logger.error(f"Failed to initialize FastAPI Limiter: {limiter_e}")
    #         
    # except Exception as e:
    #     logger.error(f"Critical error during Redis services initialization: {e}")

    try:
        from app.core.database import Base, engine
        Base.metadata.create_all(bind=engine)
        logger.info("Database tables created successfully")
    except Exception as e:
        logger.error(f"Could not create database tables on startup: {e}")
    
    yield
    # Shutdown logic (closing redis etc) could go here if needed

app = FastAPI(
    title="aide API",
    version="1.0.0",
    lifespan=lifespan
)

# Enable CORS using whitelist from settings
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



# Include API v1
app.include_router(api_router, prefix="/api/v1")


@app.get("/")
def root():
    return {"message": "Aide Backend Running"}


from fastapi import WebSocket, WebSocketDisconnect
import asyncio

@app.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: int):
    await websocket.accept()
    
    from app.core.redis import get_redis_client
    redis = get_redis_client()
    pubsub = redis.pubsub()
    
    # Subscribe to a channel specific to this user
    channel_name = f"user_notifications:{user_id}"
    await pubsub.subscribe(channel_name)
    
    logger.info(f"User {user_id} connected to WebSocket and subscribed to {channel_name}")
    
    try:
        while True:
            # Check for new messages in Redis with a small timeout
            message = await pubsub.get_message(ignore_subscribe_messages=True, timeout=1.0)
            if message:
                data = message["data"]
                await websocket.send_text(f"Notification: {data}")
            
            # Keep-alive or handle client messages if needed
            # await websocket.receive_text() # This would block, so be careful
            await asyncio.sleep(0.1)
            
    except WebSocketDisconnect:
        logger.info(f"User {user_id} disconnected from WebSocket")
        await pubsub.unsubscribe(channel_name)
    except Exception as e:
        logger.error(f"WebSocket error for user {user_id}: {e}")
        await pubsub.unsubscribe(channel_name)

