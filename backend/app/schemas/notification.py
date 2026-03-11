from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, List
from datetime import datetime

class NotificationBase(BaseModel):
    title: str = Field(..., max_length=255)
    message: str

class NotificationCreate(NotificationBase):
    user_id: int

class NotificationResponse(NotificationBase):
    id: int
    user_id: int
    is_read: bool
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)
