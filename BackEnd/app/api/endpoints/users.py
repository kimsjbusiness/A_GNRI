from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import get_db
from app.models.domain import User
from app.schemas.pydantic import UserCreate, UserResponse

router = APIRouter()

@router.post("/", response_model=UserResponse)
async def register_or_update_user(user_data: UserCreate, db: AsyncSession = Depends(get_db)):
    # Check if user already exists by device_token
    stmt = select(User).where(User.device_token == user_data.device_token)
    result = await db.execute(stmt)
    user = result.scalar_one_or_none()
    
    if user:
        # Update existing user
        user.notification_time = user_data.notification_time
    else:
        # Create new user
        user = User(
            device_token=user_data.device_token,
            notification_time=user_data.notification_time
        )
        db.add(user)
    
    await db.commit()
    await db.refresh(user)
    return user
