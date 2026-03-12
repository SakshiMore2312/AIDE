from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from fastapi.encoders import jsonable_encoder

from app.core.database import get_db
from app.core.logger import logger
from app.api.v1.endpoints.deps import get_current_user, require_roles
from app.models.medical.blood_bank import BloodBank
from app.schemas.medical.blood_bank import BloodBankCreate, BloodBankUpdate, BloodBankResponse

router = APIRouter(prefix="/blood-banks", tags=["Blood Banks"])

@router.get("/", response_model=List[BloodBankResponse])
async def get_blood_banks(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    blood_group: Optional[str] = Query(None, description="Check availability for blood group, e.g., 'A+'"),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    query = db.query(BloodBank).filter(BloodBank.is_active == True)
    
    # Simple check if blood_group exists in JSON (SQLite/Postgres JSON supports differ slightly, but this is a rough filter)
    # For production, you might want more complex JSON queries if using Postgres
    if blood_group:
        # This is a very basic filter. For SQLite it's tricky, for Postgres use JSONB containment.
        # Here we just fetch and filter in Python if needed, or use a simple LIKE on the column for rough matches.
        pass # Better to implement specific DB filters depending on the DB type
        
    blood_banks = query.offset(skip).limit(limit).all()
    
    if blood_group:
        # Final filter in Python for availability
        blood_banks = [bb for bb in blood_banks if bb.blood_group_units and bb.blood_group_units.get(blood_group, 0) > 0]
        
    return blood_banks


@router.get("/{blood_bank_id}", response_model=BloodBankResponse)
async def get_blood_bank(
    blood_bank_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    bb = db.query(BloodBank).filter(BloodBank.id == blood_bank_id, BloodBank.is_active == True).first()
    if not bb:
        raise HTTPException(status_code=404, detail="Blood Bank not found")
    return bb

@router.post("/", response_model=BloodBankResponse, status_code=201)
async def create_blood_bank(
    bb_data: BloodBankCreate,
    db: Session = Depends(get_db),
    current_user = Depends(require_roles(["ADMIN"]))
):
    bb_dict = jsonable_encoder(bb_data)
    bb = BloodBank(**bb_dict)
    db.add(bb)
    db.commit()
    db.refresh(bb)
    logger.info(f"Blood Bank added: {bb.name} by admin {current_user.id}")
    return bb

@router.patch("/{blood_bank_id}", response_model=BloodBankResponse)
async def update_blood_bank(
    blood_bank_id: int,
    bb_data: BloodBankUpdate,
    db: Session = Depends(get_db),
    current_user = Depends(require_roles(["ADMIN"]))
):
    bb = db.query(BloodBank).filter(BloodBank.id == blood_bank_id, BloodBank.is_active == True).first()
    if not bb:
        raise HTTPException(status_code=404, detail="Blood Bank not found")
    
    update_data = jsonable_encoder(bb_data, exclude_unset=True)
    for key, value in update_data.items():
        setattr(bb, key, value)
    
    db.commit()
    db.refresh(bb)
    logger.info(f"Blood Bank updated: {blood_bank_id} by admin {current_user.id}")
    return bb

@router.delete("/{blood_bank_id}", status_code=204)
async def delete_blood_bank(
    blood_bank_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(require_roles(["ADMIN"]))
):
    bb = db.query(BloodBank).filter(BloodBank.id == blood_bank_id, BloodBank.is_active == True).first()
    if not bb:
        raise HTTPException(status_code=404, detail="Blood Bank not found")
    
    # Soft delete
    bb.is_active = False
    db.commit()
    logger.warning(f"Blood Bank deleted: {blood_bank_id} by admin {current_user.id}")
    return None
