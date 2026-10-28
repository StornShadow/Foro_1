from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel





class StatusBase(BaseModel):
    statusId: int
    statusName: str
    statusCreationDate: datetime
    statusCreatorId: int
    statusModificationDate: Optional[datetime] = None
    statusModificatorId: Optional[int] = None
    statusEnable: bool


class StatusCreate(BaseModel):
    statusName: str
    statusCreatorId: int
    statusEnable: Optional[bool] = True


class StatusUpdate(BaseModel):
    statusId: int
    statusName: Optional[str] = None
    statusModificationDate: Optional[datetime] = None
    statusModificatorId: int
    statusEnable: Optional[bool] = None


class LtsStatus(BaseModel):
    statuses: List[StatusBase] 