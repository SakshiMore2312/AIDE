from app.core.database import SessionLocal
from app.models.user import User

db = SessionLocal()
try:
    admin = db.query(User).filter(User.email == "admin@educareconnect.com").first()
    if admin:
        admin.email = "admin@aide.com"
        db.commit()
        print("Admin email updated from admin@educareconnect.com to admin@aide.com")
    else:
        print("Admin user with old email not found. Checking if admin@aide.com already exists...")
        exists = db.query(User).filter(User.email == "admin@aide.com").first()
        if exists:
            print("Admin user with admin@aide.com already exists!")
        else:
            print("Neither old nor new admin email found. Run scripts/init_db.py if needed.")
finally:
    db.close()
