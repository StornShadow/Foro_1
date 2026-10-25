from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


class RoleBase(BaseModel):
    rolId: int
    rolName: str
    rolCreationDate: datetime
    rolCreatorId: int
    rolModificationDate: Optional[datetime] = None
    rolModificatorId: Optional[int] = None
    rolEnable: bool


class RoleCreate(BaseModel):
    rolName: str
    rolCreatorId: int
    rolEnable: Optional[bool] = True


class RoleUpdate(BaseModel):
    rolId: int
    rolName: Optional[str] = None
    rolModificationDate: Optional[datetime] = None
    rolModificatorId: int
    rolEnable: Optional[bool] = None


class LtsRoles(BaseModel):
    roles: List[RoleBase]