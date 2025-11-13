from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app import database, schemas

from .. import schemas
from ..database import get_db
from ..repositories import auth
from ..security import get_user

router = APIRouter(prefix="", tags=["auth"])
