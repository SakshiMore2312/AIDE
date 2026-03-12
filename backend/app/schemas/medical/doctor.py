from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class DoctorBase(BaseModel):
    hospital_id: int
    name: str
    specialization: str
    consultation_fee: Optional[float] = None
    rating: float = 0.0
    experience_years: Optional[int] = None
    availability_hours: Optional[str] = None
    contact_number: Optional[str] = None

class DoctorCreate(DoctorBase):
    pass

class DoctorUpdate(BaseModel):
    hospital_id: Optional[int] = None
    name: Optional[str] = None
    specialization: Optional[str] = None
    consultation_fee: Optional[float] = None
    rating: Optional[float] = None
    experience_years: Optional[int] = None
    availability_hours: Optional[str] = None
    contact_number: Optional[str] = None

class DoctorResponse(DoctorBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
