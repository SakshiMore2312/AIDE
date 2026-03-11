from pydantic import BaseModel

class SettingsUpdate(BaseModel):
    push_notifications: bool | None = None

class SettingsResponse(BaseModel):
    push_notifications: bool
