from fastapi import APIRouter
from app.api.v1.endpoints.medical import hospitals, doctors, blood_banks, ambulances

router = APIRouter()

router.include_router(hospitals.router)
router.include_router(doctors.router)
router.include_router(blood_banks.router)
router.include_router(ambulances.router)
