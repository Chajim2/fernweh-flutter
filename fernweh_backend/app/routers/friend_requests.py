from fastapi import APIRouter, Depends, HTTPException, status
from uuid import UUID
from sqlmodel import Session, select, or_, and_
from app.oauth2 import get_current_user
from app.database import get_session 
import app.schemas as schemas, app.models as models
from app.routers.friendships import friendship_exists

router = APIRouter(tags=["friend_requests"], prefix="/friend_requests")

def friend_request_exists(friend_request : models.FriendRequest, user : models.User, db : Session):
    statement = select(models.FriendRequest).where(or_(
                                                and_(models.FriendRequest.user_id == user.id, models.FriendRequest.friend_id == friend_request.friend_id),
                                                and_(models.FriendRequest.user_id == friend_request.friend_id, models.FriendRequest.friend_id == user.id)
                                            )
                                        )
    return db.exec(statement).first() != None

   
@router.post("/{friend_id}")
def decide_friend_request(friend_id : UUID, decision : schemas.FriendRequestDecision, db : Session = Depends(get_session),
                          current_user : models.User = Depends(get_current_user)):
    statement = select(models.FriendRequest).where(models.FriendRequest.friend_id == current_user.id, models.FriendRequest.user_id == friend_id)
    friendrequest = db.exec(statement).first()
    
    if friendrequest:
        db.delete(friendrequest)
        db.commit()
    else:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
        
    if decision.accepted:
        friendship = models.FriendShip(user_id = current_user.id, friend_id = friend_id) 
        db.add(friendship)
        db.commit()
        db.refresh(friendship) 
        return {'status' : "accepted", "friendship" : friendship}

    return {"status" : "rejected"}    

@router.post("/")
def create_friend_request(friend_request : schemas.FriendRequest, db : Session = Depends(get_session), current_user : models.User = Depends(get_current_user)):
    new_friend_request = models.FriendRequest(user_id = current_user.id, friend_id = friend_request.friend_id)
    if friend_request_exists(new_friend_request, current_user, db):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Friend request already exists between these two users")
    
    if friendship_exists(new_friend_request, current_user, db):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="These two users are already friends")
    
    db.add(new_friend_request)
    db.commit()
    db.refresh(new_friend_request)
    
    return new_friend_request

@router.get("/")
def get_all_friend_requests(db : Session = Depends(get_session), current_user : models.User = Depends(get_current_user)):
    statement = select(models.FriendRequest).where(models.FriendRequest.friend_id == current_user.id)
    print(current_user.username)
    return db.exec(statement).all()

   