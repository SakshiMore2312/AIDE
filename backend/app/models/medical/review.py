from sqlalchemy import Column, Integer, Text, String, DateTime, Boolean, ForeignKey, CheckConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class MedicalReview(Base):
    __tablename__ = "medical_reviews"

    id = Column(Integer, primary_key=True, index=True)
    content = Column(Text, nullable=False)
    rating = Column(Integer, nullable=False)

    __table_args__ = (
        CheckConstraint("rating >= 0 AND rating <= 5", name="check_medical_rating_range"),
    )

    hospital_id = Column(Integer, ForeignKey("hospitals.id", ondelete="CASCADE"), nullable=True, index=True)
    doctor_id = Column(Integer, ForeignKey("doctors.id", ondelete="CASCADE"), nullable=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    # Relationships
    user = relationship("User", back_populates="medical_reviews")
    hospital = relationship("Hospital", back_populates="reviews")
    doctor = relationship("Doctor", back_populates="reviews")

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
