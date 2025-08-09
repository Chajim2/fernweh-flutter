import app.models as models
from sqlmodel.ext.asyncio.session import AsyncSession
from typing import List
from sqlmodel import or_, and_, select, Session
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from app.oauth2 import get_current_user
from app.database import get_session, get_async_session
import app.schemas as schemas

router = APIRouter(tags=["friendships"], prefix="/friendships")

async def get_all_friends(user_id: UUID, db: AsyncSession) -> List[schemas.UserNoPassword]:
    statement = select(models.FriendShip).where(
        or_(
            models.FriendShip.friend_id == user_id,
            models.FriendShip.user_id == user_id
        )
    )
    results = await db.exec(statement)
    friendships = results.all()
    friends = []

    for friendship in friendships:
        friend_id = friendship.friend_id if friendship.user_id == user_id else friendship.user_id

        friend_stmt = select(models.User).where(models.User.id == friend_id)
        result = await db.exec(friend_stmt)
        friend_info = result.first()
        if friend_info:
            friend = schemas.UserNoPassword(id=friend_info.id, username=friend_info.username)
            friends.append(friend)

    return friends

def friendship_exists(friend_request : models.FriendRequest, user : models.User, db : Session) -> bool:
    statement = select(models.FriendShip).where(or_(
                                                and_(models.FriendShip.user_id == user.id, models.FriendShip.friend_id == friend_request.friend_id),
                                                and_(models.FriendShip.user_id == friend_request.friend_id, models.FriendShip.friend_id == user.id)
                                            )
                                        )
    return db.exec(statement).first() != None

@router.get("/")
def get_all_friends_endpoint( current_user : models.User = Depends(get_current_user), db : AsyncSession = Depends(get_async_session)):
    return get_all_friends(current_user.id, db)

@router.delete("/{friend_id}")
def delete_friendship(friend_id : UUID, current_user : models.User = Depends(get_current_user), db : Session = Depends(get_session)):
    statement = select(models.FriendShip).where(or_(
                                                and_(models.FriendShip.user_id == current_user.id, models.FriendShip.friend_id == friend_id),
                                                and_(models.FriendShip.user_id == friend_id, models.FriendShip.friend_id == current_user.id)
                                            )
                                        )
    friendship = db.exec(statement).first()

    if not friendship:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Friendship does not exist")

    db.delete(friendship)
    db.commit()
    
    return {"message" : f"Sucesfully removed from your friends"} 
