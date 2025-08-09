from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import ColumnElement
from sqlmodel import Session, select
from typing import cast
from sqlmodel.ext.asyncio.session import AsyncSession

from app.database import get_async_session, get_session
from app.oauth2 import get_current_user
import app.models as models
import app.schemas as schemas

router = APIRouter(prefix="/entries", tags=["entries"])


@router.get("/")
def get_all_entries(
    db: Session = Depends(get_session),
    current_user: models.User = Depends(get_current_user),
):

    statement = (
        select(models.Entry)
        .join(models.User, cast(ColumnElement[bool], models.Entry.author_id == models.User.id))
        .where(models.Entry.author_id == current_user.id)
    )

    return db.exec(statement).all()


@router.post("/")
def post_entry(
    entry_info: schemas.EntryInfo,
    db: Session = Depends(get_session),
    current_user: models.User = Depends(get_current_user),
):
    try:
        new_entry = models.Entry(
            author_id=current_user.id,
            title=entry_info.title,
            text=entry_info.text,
            is_private=entry_info.is_private,
        )
    except Exception as ex:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid post data provided: {ex}",
        )

    db.add(new_entry)
    db.commit()
    db.refresh(new_entry)
    return new_entry


@router.get("/{entry_id}")
def get_entry_with_comments(
    entry_id: int,
    db: Session = Depends(get_session),
    current_user: models.User = Depends(get_current_user),
):
    statement = select(models.Entry).where(models.Entry.id == entry_id)
    entry = db.exec(statement).first()

    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Entry with id {entry_id} not found",
        )

    statement = select(models.Comment).where(models.Comment.parent_id == entry_id)
    comments = db.exec(statement).all()

    return {"entry": entry, "comments": comments}

@router.get('/feed')
def get_all_relevant_entries(db : AsyncSession = Depends(get_async_session), current_user : models.User = Depends(get_current_user)):
    
    return 