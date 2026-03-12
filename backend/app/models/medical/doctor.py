from sqlalchemy import Column, Integer, String, Text, Float, DateTime, ForeignKey, func, Boolean
from sqlalchemy.orm import relationship
from app.core.database import Base

class Doctor(Base):
    __tablename__ = "doctors"

    id = Column(Integer, primary_key=True, index=True)
    hospital_id = Column(Integer, ForeignKey("hospitals.id"), nullable=False)
    name = Column(String(255), nullable=False, index=True)
    specialization = Column(String(255), nullable=False, index=True)
    consultation_fee = Column(Float, nullable=True)
    rating = Column(Float, default=0.0)
    experience_years = Column(Integer, nullable=True)
    availability_hours = Column(String(255), nullable=True)  # e.g., "9:00 AM - 5:00 PM"
    contact_number = Column(String(20), nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    # Soft delete
    is_active = Column(Boolean, default=True, nullable=False)

    # Relationships
    hospital = relationship("Hospital", back_populates="doctors")
    reviews = relationship("MedicalReview", back_populates="doctor", cascade="all, delete-orphan")
