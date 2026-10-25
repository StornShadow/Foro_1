from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


class TaskCommentBase(BaseModel):
    taskCommentId: int
    taskCommentParentLink: int
    taskCommentOwner: int
    taskCommentText: str
    taskCommentCreationDate: datetime
    taskCommentCreatorId: int
    taskCommentModificationDate: Optional[datetime] = None
    taskCommentModificatorId: Optional[int] = None
    taskCommentStatus: bool


class TaskCommentCreate(BaseModel):
    taskCommentParentLink: int
    taskCommentOwner: int
    taskCommentText: str
    taskCommentCreatorId: int
    taskCommentStatus: Optional[bool] = True


class TaskCommentUpdate(BaseModel):
    taskCommentId: int
    taskCommentText: Optional[str] = None
    taskCommentModificationDate: Optional[datetime] = None
    taskCommentModificatorId: int
    taskCommentStatus: Optional[bool] = None


class LtsTaskComments(BaseModel):
    taskComments: List[TaskCommentBase]