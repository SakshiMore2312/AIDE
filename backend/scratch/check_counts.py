
import sys
sys.path.append('.')
from app.core.database import engine
from sqlalchemy import text

def check_counts():
    with engine.connect() as conn:
        for table in ['colleges', 'hostels', 'pgs', 'mess', 'coachings', 'schools']:
            try:
                count = conn.execute(text(f'select count(*) from {table}')).scalar()
                print(f"{table}: {count}")
            except Exception as e:
                print(f"{table}: Error {e}")

if __name__ == "__main__":
    check_counts()
