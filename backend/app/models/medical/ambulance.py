from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, func
from app.core.database import Base

class Ambulance(Base):
    __tablename__ = "ambulances"

    id = Column(Integer, primary_key=True, index=True)
    provider_name = Column(String(255), nullable=False, index=True)
    type = Column(String(100), nullable=False)  # e.g., Basic Life Support, ALS, Air Ambulance
    cost_per_km = Column(Float, nullable=False)
    availability = Column(Boolean, default=True)
    contact_number = Column(String(20), nullable=False)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    base_address = Column(String(255), nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    # Soft delete
    is_active = Column(Boolean, default=True, nullable=False)
