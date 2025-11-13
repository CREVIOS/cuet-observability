import datetime
import enum
import uuid
from typing import List, Optional

from pydantic import BaseModel, ConfigDict, EmailStr


class BaseResponse(BaseModel):
    message: str


class User(BaseModel):
    id: uuid.UUID

    model_config = ConfigDict(from_attributes=True, extra="ignore")
