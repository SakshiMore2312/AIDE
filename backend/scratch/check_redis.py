
import asyncio
from app.core.redis import get_redis_client
from app.core.database import SessionLocal
from app.models.education.colleges import College

async def main():
    client = get_redis_client()
    try:
        # Check if geo index has members
        count = await client.zcard("geo:colleges")
        print(f"Geo Index 'geo:colleges' count: {count}")
        
        # Try to get pos of some member
        if count > 0:
            members = await client.zrange("geo:colleges", 0, 0)
            if members:
                pos = await client.geopos("geo:colleges", members[0])
                print(f"Position of {members[0]}: {pos}")
    except Exception as e:
        print(f"Redis Error: {e}")

if __name__ == "__main__":
    asyncio.run(main())
