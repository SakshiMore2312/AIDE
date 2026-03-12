from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from fastapi.encoders import jsonable_encoder

from app.core.database import get_db
from app.core.logger import logger
from app.api.v1.endpoints.deps import get_current_user, require_roles
from app.models.medical.doctor import Doctor
from app.models.medical.review import MedicalReview
from app.schemas.medical.doctor import DoctorCreate, DoctorUpdate, DoctorResponse
from app.schemas.medical.review import MedicalReviewCreate, MedicalReviewResponse

router = APIRouter(prefix="/doctors", tags=["Doctors"])

@router.get("/", response_model=List[DoctorResponse])
async def get_doctors(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    specialization: Optional[str] = Query(None),
    hospital_id: Optional[int] = Query(None),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    query = db.query(Doctor).filter(Doctor.is_active == True)
    if specialization:
        query = query.filter(Doctor.specialization.ilike(f"%{specialization}%"))
    if hospital_id:
        query = query.filter(Doctor.hospital_id == hospital_id)
    
    doctors = query.offset(skip).limit(limit).all()
    return doctors

@router.get("/{doctor_id}", response_model=DoctorResponse)
async def get_doctor(
    doctor_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    doctor = db.query(Doctor).filter(Doctor.id == doctor_id, Doctor.is_active == True).first()
    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor not found")
    return doctor

@router.post("/", response_model=DoctorResponse, status_code=201)
async def create_doctor(
    doctor_data: DoctorCreate,
    db: Session = Depends(get_db),
    current_user = Depends(require_roles(["ADMIN"]))
):
    doctor_dict = jsonable_encoder(doctor_data)
    doctor = Doctor(**doctor_dict)
    db.add(doctor)
    db.commit()
    db.refresh(doctor)
    logger.info(f"Doctor added: {doctor.name} by admin {current_user.id}")
    return doctor

@router.patch("/{doctor_id}", response_model=DoctorResponse)
async def update_doctor(
    doctor_id: int,
    doctor_data: DoctorUpdate,
    db: Session = Depends(get_db),
    current_user = Depends(require_roles(["ADMIN"]))
):
    doctor = db.query(Doctor).filter(Doctor.id == doctor_id, Doctor.is_active == True).first()
    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor not found")
    
    update_data = jsonable_encoder(doctor_data, exclude_unset=True)
    for key, value in update_data.items():
        setattr(doctor, key, value)
    
    db.commit()
    db.refresh(doctor)
    logger.info(f"Doctor updated: {doctor_id} by admin {current_user.id}")
    return doctor

@router.delete("/{doctor_id}", status_code=204)
async def delete_doctor(
    doctor_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(require_roles(["ADMIN"]))
):
    doctor = db.query(Doctor).filter(Doctor.id == doctor_id, Doctor.is_active == True).first()
    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor not found")
    
    # Soft delete
    doctor.is_active = False
    db.commit()
    logger.warning(f"Doctor deleted: {doctor_id} by admin {current_user.id}")
    return None

# Reviews
@router.get("/{doctor_id}/reviews", response_model=List[MedicalReviewResponse])
async def get_doctor_reviews(
    doctor_id: int,
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    db: Session = Depends(get_db)
):
    reviews = db.query(MedicalReview).filter(
        MedicalReview.doctor_id == doctor_id,
        MedicalReview.is_active == True
    ).offset(skip).limit(limit).all()
    return reviews

@router.post("/{doctor_id}/reviews", response_model=MedicalReviewResponse, status_code=201)
async def create_doctor_review(
    doctor_id: int,
    review_data: MedicalReviewCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    doctor = db.query(Doctor).filter(Doctor.id == doctor_id).first()
    if not doctor:
        raise HTTPException(status_code=404, detail="Doctor not found")
    
    review_dict = review_data.model_dump()
    review_dict["user_id"] = current_user.id
    review_dict["doctor_id"] = doctor_id
    
    review = MedicalReview(**review_dict)
    db.add(review)
    db.commit()
    db.refresh(review)
    logger.info(f"Medical review added for doctor {doctor_id} by user {current_user.id}")
    return review
