from app.core.database import SessionLocal
from app.models.stay.pg import PG

def check_pgs():
    db = SessionLocal()
    count = db.query(PG).count()
    print(f"Total PGs in database: {count}")
    pgs = db.query(PG).all()
    for pg in pgs:
        print(f"PG: {pg.name} (Active: {pg.is_active})")
    db.close()

if __name__ == "__main__":
    check_pgs()
