from fastapi.security import OAuth2PasswordRequestForm
from app.schemas import LoginInfo, LoginResponse
from sqlmodel import select, Session
from fastapi import Depends, FastAPI, HTTPException, Response, status, APIRouter
import app.utils as utils, app.models as models
from app.database import get_session
import app.oauth2 as oauth2

router = APIRouter()

@router.post('/login', response_model=LoginResponse)
def login(loginInfo : OAuth2PasswordRequestForm = Depends(), db : Session = Depends(get_session)):
    hashed_password = hash(loginInfo.password)
    statement = select(models.User).where(models.User.username == loginInfo.username)
    user = db.exec(statement).first()

    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Incorrect user credentials")
    
    if not utils.verify(loginInfo.password, user.password):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Incorrect user credentials")
    
    token = oauth2.create_access_token(data = {"user_id" : str(user.id)}) 
    return {"message" : "sucesfully received account info", "success" : True, "access_token" : token, "token_type" : "bearer"}

@router.post('/register')
def register(loginInfo : LoginInfo, db : Session = Depends(get_session)):
    loginInfo.password = utils.hash(loginInfo.password)
    
    new_user = models.User(**loginInfo.model_dump())
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return {"message" : "sucesfully received account info"}
 