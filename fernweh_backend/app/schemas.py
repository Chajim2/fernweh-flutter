from datetime import datetime
from typing import Optional
from pydantic import BaseModel
from uuid import UUID

from yaml import Token

class LoginInfo(BaseModel):
    username: str
    password: str

class TokenBase(BaseModel):
    access_token: str
    refresh_token: str
    token_type: Optional[str]

class LoginResponse(TokenBase):
    success : bool
    message : str = ""

class TokenData(BaseModel):
    id : Optional[str]

class FriendRequest(BaseModel):
    friend_id : UUID

class FriendRequestDecision(BaseModel):
    accepted : bool

class EntryBase(BaseModel):
    text : str

class EntryInfo(EntryBase):
    title : str
    is_private : bool = False

class CommentInfo(BaseModel):
    text : str

class UserBase(BaseModel):
    username : str

class UserNoPassword(UserBase):
    id : UUID

class RefreshInfo(BaseModel):
    refresh_token : str

class FeedItem(BaseModel):
    entry_id : int
    text : str
    author_name : str
    timestamp : datetime
    type : str
    