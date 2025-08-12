from datetime import datetime
from re import S
from typing import Optional
from pydantic import BaseModel
from uuid import UUID

class LoginInfo(BaseModel):
    username: str
    password: str
  
class LoginResponse(BaseModel):
    success : bool
    access_token : str = ""
    message : str = ""
    token_type : Optional['str']

class TokenData(BaseModel):
    id : Optional[str]

class FriendRequest(BaseModel):
    friend_id : UUID

class FriendRequestDecision(BaseModel):
    accepted : bool

class EntryInfo(BaseModel):
    title : str
    text : str
    is_private : bool = False

class CommentInfo(BaseModel):
    text : str

class UserNoPassword(BaseModel):
    username : str
    id : UUID

class FeedItem(BaseModel):
    entry_id : int
    text : str
    author_name : str
    timestamp : datetime
    