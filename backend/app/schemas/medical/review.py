from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class MedicalReviewBase(BaseModel):
    content: str
    rating: int = Field(..., ge=0, le=5)
    hospital_id: Optional[int] = None
    doctor_id: Optional[int] = None

class MedicalReviewCreate(MedicalReviewBase):
    pass

class MedicalReviewUpdate(BaseModel):
    content: Optional[str] = None
    rating: Optional[int] = Field(None, ge=0, le=5)

class MedicalReviewResponse(MedicalReviewBase):
    id: int
    user_id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
