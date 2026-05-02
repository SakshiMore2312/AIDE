from app.core.database import SessionLocal
from app.models.user import User, UserRole
from app.core.security import get_password_hash

def setup():
    db = SessionLocal()
    email = "admin@aide.com"
    user = db.query(User).filter(User.email == email).first()
    if not user:
        user = User(
            full_name="Admin",
            email=email,
            hashed_password=get_password_hash("admin123"),
            role=UserRole.ADMIN,
            is_active=True,
            is_verified=True
        )
        db.add(user)
    else:
        user.hashed_password = get_password_hash("admin123")
        user.is_active = True
        user.is_verified = True
        user.role = UserRole.ADMIN
    db.commit()
    db.close()
    print("User admin@aide.com is ready with password admin123")

if __name__ == "__main__":
    setup()
