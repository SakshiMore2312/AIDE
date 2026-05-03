#!/usr/bin/env python3
import sys
import os
import asyncio

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.core.database import SessionLocal, engine, Base
from app.models.user import User, UserRole
from app.models.education.colleges import College
from app.models.medical.hospital import Hospital
from app.models.stay.pg import PG
from app.core.security import get_password_hash
from app.core.redis import geo_add_location, get_redis_client

def create_tables():
    print("Creating tables...")
    try:
        Base.metadata.create_all(bind=engine)
        print("Tables created successfully.")
    except Exception as e:
        print(f"Error creating tables: {e}")

def seed_admin():
    db: Session = SessionLocal()
    try:
        print("Checking for admin user...")
        admin = db.query(User).filter(User.email == "admin@aide.com").first()
        if not admin:
            admin = User(
                email="admin@aide.com",
                hashed_password=get_password_hash("admin123"),
                full_name="System Admin",
                role=UserRole.ADMIN,
                is_active=True
            )
            db.add(admin)
            db.commit()
            print("Admin user created: admin@aide.com / admin123")
        else:
            print("Admin user already exists.")
    except Exception as e:
        print(f"Error seeding admin: {e}")
        db.rollback()
    finally:
        db.close()

async def sync_redis():
    print("Syncing data to Redis geo-indices...")
    db: Session = SessionLocal()
    try:
        redis_client = await get_redis_client()
        if not redis_client:
            print("Redis not available. Skipping sync.")
            return

        # Colleges
        colleges = db.query(College).all()
        for c in colleges:
            if c.latitude and c.longitude:
                await geo_add_location("geo:colleges", c.longitude, c.latitude, c.id)
        print(f"Synced {len(colleges)} colleges to Redis.")

        # Hospitals
        hospitals = db.query(Hospital).all()
        for h in hospitals:
            if h.latitude and h.longitude:
                await geo_add_location("geo:hospitals", h.longitude, h.latitude, h.id)
        print(f"Synced {len(hospitals)} hospitals to Redis.")

        # PGs
        pgs = db.query(PG).all()
        for p in pgs:
            if p.latitude and p.longitude:
                await geo_add_location("geo:pgs", p.longitude, p.latitude, p.id)
        print(f"Synced {len(pgs)} PGs to Redis.")

    except Exception as e:
        print(f"Error syncing to Redis: {e}")
    finally:
        db.close()

def main():
    create_tables()
    seed_admin()
    try:
        asyncio.run(sync_redis())
    except Exception as e:
        print(f"Async sync failed: {e}")
    print("Setup complete.")

if __name__ == "__main__":
    main()
