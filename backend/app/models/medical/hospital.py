from sqlalchemy import Column, Integer, String, Text, Float, DateTime, func, Boolean
from sqlalchemy.orm import relationship
from app.core.database import Base

class Hospital(Base):
    __tablename__ = "hospitals"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, index=True)
    category = Column(String(100), nullable=True)  # e.g., General, Multi-speciality
    address = Column(Text, nullable=False)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    available_beds = Column(Integer, default=0)
    icu_beds = Column(Integer, default=0)
    emergency_contact = Column(String(20), nullable=False)
    phone_number = Column(String(20), nullable=True)
    email = Column(String(255), nullable=True)
    website = Column(String(255), nullable=True)
    google_maps_link = Column(Text, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    # Soft delete
    is_active = Column(Boolean, default=True, nullable=False)

    # Relationships
    doctors = relationship("Doctor", back_populates="hospital", cascade="all, delete-orphan")
    reviews = relationship("MedicalReview", back_populates="hospital", cascade="all, delete-orphan")
