from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select

from sqlmodel.ext.asyncio.session import AsyncSession
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker



DATABASE_URL = "postgresql://postgres:132465@localhost/fernweh_db"

ASYNC_DATABASE_URL = "postgresql+asyncpg://postgres:132465@localhost/fernweh_db"
engine = create_engine(DATABASE_URL)
async_engine = create_async_engine(ASYNC_DATABASE_URL, echo=True)

AsyncSessionLocal = async_sessionmaker(bind = async_engine, expire_on_commit=False)

async def create_db_and_tables():
    SQLModel.metadata.create_all(engine)
    async with async_engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)
    print("created all tables")


def get_session():
    with Session(engine) as session:
        yield session

async def get_async_session():
    async with AsyncSessionLocal() as session:
        yield session


SessionDep = Annotated[Session, Depends(get_session)]

