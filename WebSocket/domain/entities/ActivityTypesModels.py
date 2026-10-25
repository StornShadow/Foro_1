from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


class ActivityTypeBase(BaseModel):
    activityTypeId: int
    activityTypeName: str
    activityTypeCreationDate: datetime
    activityTypeCreatorId: int
    activityTypeModificationDate: Optional[datetime] = None
    activityTypeModificatorId: Optional[int] = None
    activityTypeEnable: bool


class ActivityTypeCreate(BaseModel):
    activityTypeName: str
    activityTypeCreatorId: int
    activityTypeEnable: Optional[bool] = True


class ActivityTypeUpdate(BaseModel):
    activityTypeId: int
    activityTypeName: Optional[str] = None
    activityTypeModificationDate: Optional[datetime] = None
    activityTypeModificatorId: int
    activityTypeEnable: Optional[bool] = None


class LtsActivityTypes(BaseModel):
    activityTypes: List[ActivityTypeBase]