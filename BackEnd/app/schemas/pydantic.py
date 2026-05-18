from pydantic import BaseModel, ConfigDict
from datetime import date, datetime, time
from typing import List, Optional

# --- Report Schemas ---

class TrendingKeywordSchema(BaseModel):
    ranking: int
    keyword: str
    search_url: str
    
    model_config = ConfigDict(from_attributes=True)

class ReportImageSchema(BaseModel):
    image_id: int
    referenced_sentence: str
    # image_data is BYTEA, usually returned as Base64 in JSON or via separate stream
    # For now, let's just include the sentence and ID.
    
    model_config = ConfigDict(from_attributes=True)

class DailyReportSchema(BaseModel):
    report_id: int
    report_date: date
    final_summaries_kr: List[str]
    top_3_sentences: List[str]
    market_sentiment: str
    stock_theme: str
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)

class FullReportResponse(BaseModel):
    report: DailyReportSchema
    keywords: List[TrendingKeywordSchema]
    # images: List[ReportImageSchema] # Images usually handled via separate URL/Base64

# --- User Schemas ---

class UserCreate(BaseModel):
    device_token: str
    notification_time: Optional[time] = time(hour=6, minute=0)

class UserResponse(BaseModel):
    user_id: int
    device_token: str
    notification_time: time
    
    model_config = ConfigDict(from_attributes=True)
