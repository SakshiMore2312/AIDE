from datetime import datetime
from sqlalchemy import (
    Column,
    Integer,
    Text,
    String,
    DateTime,
    Boolean,
    ForeignKey,
    CheckConstraint
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class Review(Base):
    """
    Review model stores user feedback (rating + content) for any entity.
    
    Each review is linked to ONE entity through foreign keys:
    - college_id
    - school_id
    - hostel_id
    - mess_id
    - coaching_id
    
    Only ONE of these will be non-null for any given review.
    """

    __tablename__ = "reviews"

    id = Column(Integer, primary_key=True, index=True)
    
    # Review Content
    content = Column(Text, nullable=False)
    rating = Column(Integer, nullable=False)

    # Ensure rating is between 1 and 5
    __table_args__ = (
        CheckConstraint(
            "rating >= 1 AND rating <= 5",
            name="check_rating_range"
        ),
    )

    # Foreign Keys to different entity types (polymorphic)
    college_id = Column(Integer, ForeignKey("colleges.id", ondelete="CASCADE"), nullable=True, index=True)
    school_id = Column(Integer, ForeignKey("schools.id", ondelete="CASCADE"), nullable=True, index=True)
    hostel_id = Column(Integer, ForeignKey("hostels.id", ondelete="CASCADE"), nullable=True, index=True)
    mess_id = Column(Integer, ForeignKey("mess.id", ondelete="CASCADE"), nullable=True, index=True)
    coaching_id = Column(Integer, ForeignKey("coachings.id", ondelete="CASCADE"), nullable=True, index=True)

    # User who wrote the review
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False
    )

    # Relationships
    user = relationship("User", back_populates="reviews")
    college = relationship("College", back_populates="reviews")
    school = relationship("School", back_populates="reviews")
    hostel = relationship("Hostel", back_populates="reviews")
    mess = relationship("Mess", back_populates="reviews")
    coaching = relationship("Coaching", back_populates="reviews")

    # Timestamps
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False
    )

    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False
    )

    # Soft Delete
    is_active = Column(Boolean, default=True, nullable=False)
