from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from sqlalchemy import ColumnElement
from sqlmodel import Session, select, or_
from typing import cast
from sqlmodel.ext.asyncio.session import AsyncSession
from sqlalchemy.orm import selectinload

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


@router.get('/feed', response_model=List[schemas.FeedItem])
async def get_all_relevant_entries(db : AsyncSession = Depends(get_async_session), current_user : models.User = Depends(get_current_user)):
    print("HRE I AM")
    #create a list of all of the ids of the user's friends
    friendship_statement = select(models.FriendShip).where(
        or_(
            models.FriendShip.user_id == current_user.id,
            models.FriendShip.friend_id == current_user.id
            #TODO STUCK HERE
        )
    )
    friendship_result = await db.exec(friendship_statement)
    
    friend_ids = set()
    for friendship in friendship_result.all():
        if friendship.user_id != current_user.id:
            friend_ids.add(friendship.user_id)
        if friendship.friend_id != current_user.id:
            friend_ids.add(friendship.friend_id)
    
    friend_ids.add(current_user.id)

    #get all entries wirtten by current user and his friends
    statement = select(models.Entry).where(
        cast(ColumnElement, models.Entry.author_id)
        .in_(friend_ids)).options(
        selectinload(models.Entry.author) #type: ignore
    )
    result = await db.exec(statement)
    feed_entries = [schemas.FeedItem(entry_id = entry.id,
                                    text = entry.text,
                                    author_name = entry.author.username,
                                    timestamp = entry.timestamp,
                                    type="entry")
                         for entry in result.all() if entry.timestamp is not None and entry.id is not None]


    #get all comments on user's post an by the user        
    statement = (
        select(models.Comment)
        .join(
            models.Entry,
            cast(ColumnElement, models.Comment.parent_id == models.Entry.id)
        )
        .where(or_(models.Entry.author_id == current_user.id, models.Comment.author_id == current_user.id)).
        options(selectinload(models.Comment.author)) #type: ignore
    )

    result = await db.exec(statement)

    feed_comments = [schemas.FeedItem(timestamp =  comment.timestamp,
                      author_name= comment.author.username,
                        text = comment.text,
                        entry_id= comment.parent_id,
                        type= "comment") 
                      for comment in result.all() if comment.timestamp is not None and comment.id is not None]
    
    full_feed = feed_entries + feed_comments
    full_feed.sort(key=lambda item: item.timestamp, reverse = True)
    print("GOT HREE", full_feed)
    return full_feed

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

