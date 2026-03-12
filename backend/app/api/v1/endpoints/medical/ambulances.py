from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from fastapi.encoders import jsonable_encoder

from app.core.database import get_db
from app.core.logger import logger
from app.api.v1.endpoints.deps import get_current_user, require_roles
from app.models.medical.ambulance import Ambulance
from app.schemas.medical.ambulance import AmbulanceCreate, AmbulanceUpdate, AmbulanceResponse

router = APIRouter(prefix="/ambulances", tags=["Ambulances"])

@router.get("/", response_model=List[AmbulanceResponse])
async def get_ambulances(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    type: Optional[str] = Query(None),
    available_only: bool = Query(False),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    query = db.query(Ambulance).filter(Ambulance.is_active == True)
    if type:
        query = query.filter(Ambulance.type.ilike(f"%{type}%"))
    if available_only:
        query = query.filter(Ambulance.availability == True)
    
    ambulances = query.offset(skip).limit(limit).all()
    return ambulances


@router.get("/{ambulance_id}", response_model=AmbulanceResponse)
async def get_ambulance(
    ambulance_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    ambulance = db.query(Ambulance).filter(Ambulance.id == ambulance_id, Ambulance.is_active == True).first()
    if not ambulance:
        raise HTTPException(status_code=404, detail="Ambulance not found")
    return ambulance

@router.post("/", response_model=AmbulanceResponse, status_code=201)
async def create_ambulance(
    ambulance_data: AmbulanceCreate,
    db: Session = Depends(get_db),
    current_user = Depends(require_roles(["ADMIN"]))
):
    ambulance_dict = jsonable_encoder(ambulance_data)
    ambulance = Ambulance(**ambulance_dict)
    db.add(ambulance)
    db.commit()
    db.refresh(ambulance)
    logger.info(f"Ambulance provider added: {ambulance.provider_name} by admin {current_user.id}")
    return ambulance

@router.patch("/{ambulance_id}", response_model=AmbulanceResponse)
async def update_ambulance(
    ambulance_id: int,
    ambulance_data: AmbulanceUpdate,
    db: Session = Depends(get_db),
    current_user = Depends(require_roles(["ADMIN"]))
):
    ambulance = db.query(Ambulance).filter(Ambulance.id == ambulance_id, Ambulance.is_active == True).first()
    if not ambulance:
        raise HTTPException(status_code=404, detail="Ambulance not found")
    
    update_data = jsonable_encoder(ambulance_data, exclude_unset=True)
    for key, value in update_data.items():
        setattr(ambulance, key, value)
    
    db.commit()
    db.refresh(ambulance)
    logger.info(f"Ambulance updated: {ambulance_id} by admin {current_user.id}")
    return ambulance

@router.delete("/{ambulance_id}", status_code=204)
async def delete_ambulance(
    ambulance_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(require_roles(["ADMIN"]))
):
    ambulance = db.query(Ambulance).filter(Ambulance.id == ambulance_id, Ambulance.is_active == True).first()
    if not ambulance:
        raise HTTPException(status_code=404, detail="Ambulance not found")
    
    # Soft delete
    ambulance.is_active = False
    db.commit()
    logger.warning(f"Ambulance deleted: {ambulance_id} by admin {current_user.id}")
    return None
