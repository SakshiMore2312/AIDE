from app.core.database import SessionLocal
from app.api.v1.endpoints.stay.pg import get_pgs
from app.models.user import User
import asyncio

async def test_get_pgs():
    db = SessionLocal()
    user = db.query(User).filter(User.email == "admin@aide.com").first()
    
    class Filters:
        def __init__(self):
            self.skip = 0
            self.limit = 10
            self.gender = None
            self.room_type = None
            self.query = None
            self.lat = None
            self.lon = None
            self.radius = 20.0
            self.sort_by = "name"
            self.order = "asc"
        def get_cache_key(self):
            return "test_key"
            
    try:
        results = await get_pgs(filters=Filters(), db=db, current_user=user)
        print(f"Results: {results}")
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    asyncio.run(test_get_pgs())
