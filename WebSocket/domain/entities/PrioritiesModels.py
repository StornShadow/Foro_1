from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


class PriorityBase(BaseModel):
    priorityId: int
    priorityName: str
    priorityCreationDate: datetime
    priorityCreatorId: int
    priorityModificationDate: Optional[datetime] = None
    priorityModificatorId: Optional[int] = None
    priorityEnable: bool


class PriorityCreate(BaseModel):
    priorityName: str
    priorityCreatorId: int
    priorityEnable: Optional[bool] = True


class PriorityUpdate(BaseModel):
    priorityId: int
    priorityName: Optional[str] = None
    priorityModificationDate: Optional[datetime] = None
    priorityModificatorId: int
    priorityEnable: Optional[bool] = None


class LtsPriorities(BaseModel):
    priorities: List[PriorityBase]