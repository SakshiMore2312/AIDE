from sqlalchemy import Column, Integer, String, Text, Float, DateTime, JSON, func, Boolean
from app.core.database import Base

class BloodBank(Base):
    __tablename__ = "blood_banks"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, index=True)
    address = Column(Text, nullable=False)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    
    # Using JSON to store blood group availability like {"A+": 10, "B+": 5, ...}
    blood_group_units = Column(JSON, nullable=True)
    
    price_per_unit = Column(Float, nullable=True)
    emergency_contact = Column(String(20), nullable=False)
    phone_number = Column(String(20), nullable=True)
    email = Column(String(255), nullable=True)
    website = Column(String(255), nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    # Soft delete
    is_active = Column(Boolean, default=True, nullable=False)
