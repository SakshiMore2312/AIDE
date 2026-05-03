
import asyncio
import sys
sys.path.append('.')

from app.core.database import SessionLocal
from app.core.redis import geo_add_location
from app.models.education.colleges import College
from app.models.education.coaching import Coaching
from app.models.education.mess import Mess
from app.models.education.schools import School
from app.models.stay.pg import PG
from app.models.stay.hostels import Hostel

async def sync_geo():
    db = SessionLocal()
    
    # Mapping of Model to Redis Set Name
    mappings = [
        (College, "geo:colleges"),
        (Coaching, "geo:coaching"),
        (Mess, "geo:mess"),
        (School, "geo:schools"),
        (PG, "geo:pgs"),
        (Hostel, "geo:hostels"),
    ]
    
    for model, set_name in mappings:
        items = db.query(model).all()
        print(f"Syncing {len(items)} items for {set_name}...")
        for item in items:
            if item.latitude and item.longitude:
                await geo_add_location(set_name, item.longitude, item.latitude, item.id)
    
    print("Geo-sync complete!")
    db.close()

if __name__ == "__main__":
    asyncio.run(sync_geo())
