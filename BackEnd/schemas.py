from pydantic import BaseModel, ConfigDict
from typing import List, Optional
from datetime import time, date, datetime

class AppUserCreate(BaseModel):
    device_token: str
    notification_time: Optional[time] = None

class AppUserResponse(AppUserCreate):
    user_id: int
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)

class TrendingKeywordResponse(BaseModel):
    ranking: int
    keyword: str
    search_url: str

    model_config = ConfigDict(from_attributes=True)

class ReportImageResponse(BaseModel):
    referenced_sentence: str
    image_data_base64: str

class DailyReportResponse(BaseModel):
    report_id: int
    report_date: date
    final_summaries_kr: List[str]
    top_3_sentences: List[str]
    market_sentiment: Optional[str] = None
    stock_theme: str
    keywords: List[TrendingKeywordResponse] = []
    images: List[ReportImageResponse] = []

    model_config = ConfigDict(from_attributes=True)
