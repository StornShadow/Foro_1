from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class UserBase(BaseModel):
    userId: int
    userFullName: str
    userName: str
    userEmail: str
    userRolId: int
    userCreationDate: datetime
    userCreatorId: Optional[int] = None
    userModificationDate: Optional[datetime] = None
    userModificatorId: Optional[int] = None
    userEnable: bool


class UserCreate(BaseModel):
    userFullName: str
    userName: str
    userEmail: str
    userPassword: str
    userRolId: int
    userCreatorId: Optional[int] = None


class UserUpdate(BaseModel):
    userId: int
    userFullName: Optional[str] = None
    userName: Optional[str] = None
    userEmail: Optional[str] = None
    userPassword: Optional[bytes] = None
    userRolId: Optional[int] = None
    userModificationDate: Optional[datetime] = None
    userModificatorId: int
    userEnable: Optional[bool] = None


class LtsUsers(BaseModel):
    users: List[UserBase]