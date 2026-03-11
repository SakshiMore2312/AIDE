from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User

from app.schemas.settings import SettingsResponse, SettingsUpdate

router = APIRouter(prefix="/settings", tags=["Settings"])

@router.get("/", response_model=SettingsResponse)
def get_user_settings(current_user: User = Depends(get_current_user)):
    """
    Get current user settings
    """
    return SettingsResponse(
        push_notifications=current_user.push_notifications
    )

@router.put("/", response_model=SettingsResponse)
def update_user_settings(
    settings_data: SettingsUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Update current user settings
    """
    if settings_data.push_notifications is not None:
        current_user.push_notifications = settings_data.push_notifications
        
    db.commit()
    db.refresh(current_user)
    
    return SettingsResponse(
        push_notifications=current_user.push_notifications
    )
