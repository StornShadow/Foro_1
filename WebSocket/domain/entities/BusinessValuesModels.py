from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


class BusinessValueBase(BaseModel):
    businessValueId: int
    businessValueName: str
    businessValueCreationDate: datetime
    businessValueCreatorId: int
    businessValueModificationDate: Optional[datetime] = None
    businessValueModificatorId: Optional[int] = None
    businessValueEnable: bool


class BusinessValueCreate(BaseModel):
    businessValueName: str
    businessValueCreatorId: int
    businessValueEnable: Optional[bool] = True


class BusinessValueUpdate(BaseModel):
    businessValueId: int
    businessValueName: Optional[str] = None
    businessValueModificationDate: Optional[datetime] = None
    businessValueModificatorId: int
    businessValueEnable: Optional[bool] = None


class LtsBusinessValues(BaseModel):
    businessValues: List[BusinessValueBase]