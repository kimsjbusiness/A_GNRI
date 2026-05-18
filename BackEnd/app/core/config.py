import os
from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

# backend/.env 경로 계산
base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
env_path = os.path.join(base_dir, ".env")

class Settings(BaseSettings):
    APP_NAME: str = "A_GNRI_Backend"
    DEBUG: bool = True
    
    # Database
    DATABASE_URL: str
    
    # API Keys
    NEWS_API_KEY: str
    GEMINI_API_KEY: str
    SDXL_API_URL: str
    SDXL_API_KEY: str

    model_config = SettingsConfigDict(env_file=env_path, extra='ignore')

settings = Settings()
