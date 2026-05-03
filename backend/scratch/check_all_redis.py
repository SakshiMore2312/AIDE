
import asyncio
from app.core.redis import get_redis_client

async def main():
    client = get_redis_client()
    for key in ['geo:colleges', 'geo:coaching', 'geo:mess', 'geo:schools', 'geo:pgs', 'geo:hostels']:
        try:
            count = await client.zcard(key)
            print(f"{key}: {count}")
        except Exception as e:
            print(f"{key}: Error {e}")

if __name__ == "__main__":
    asyncio.run(main())
