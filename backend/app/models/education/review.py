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

    This model is designed to support POLYMORPHIC reviews, meaning a review
    can belong to different types of entities such as:

        - College
        - School
        - Hostel
        - Mess
        - Coaching
        - Medical
        - etc.

    Instead of having separate tables like:
        college_reviews
        school_reviews
        hostel_reviews

    We use a single reviews table with:
        entity_type → tells WHAT is being reviewed
        entity_id   → tells WHICH record is being reviewed

    Example:
        entity_type = "college"
        entity_id   = 5

        → Means this review is for College with id=5
    """

    __tablename__ = "reviews"

    # -------------------------
    # Primary Key
    # -------------------------
    id = Column(Integer, primary_key=True, index=True)

    # -------------------------
    # Review Content
    # -------------------------
    content = Column(Text, nullable=False)

    rating = Column(Integer, nullable=False)

    # Ensure rating is between 1 and 5
    __table_args__ = (
        CheckConstraint(
            "rating >= 1 AND rating <= 5",
            name="check_rating_range"
        ),
    )

    # -------------------------
    # Polymorphic Review Target
    # -------------------------

    # Type of entity being reviewed
    # Example: "college", "mess", "coaching"
    entity_type = Column(String(50), nullable=False)

    # ID of the entity being reviewed
    entity_id = Column(Integer, nullable=False)

    # -------------------------
    # User Relationship
    # -------------------------
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False
    )

    user = relationship("User", back_populates="reviews")

    # -------------------------
    # Timestamps
    # -------------------------
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

    # -------------------------
    # Soft Delete
    # -------------------------
    is_active = Column(Boolean, default=True, nullable=False)
