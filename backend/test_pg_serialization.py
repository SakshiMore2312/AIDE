from app.core.database import SessionLocal
from app.api.v1.endpoints.stay.pg import get_pgs
from app.schemas.stay.pg import PGResponse
from app.models.user import User
import asyncio
import json
from fastapi.encoders import jsonable_encoder

async def test_get_pgs_serialization():
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
        print(f"Internal results count: {len(results)}")
        # Try to serialize
        serialized = jsonable_encoder(results)
        print("Serialization (jsonable_encoder) successful")
        
        # Try to validate with PGResponse
        validated = [PGResponse.model_validate(r) for r in results]
        print("Validation (PGResponse) successful")
        
    except Exception as e:
        print(f"Error during serialization/validation: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    asyncio.run(test_get_pgs_serialization())
