from sqlalchemy import Column, Integer, String, Text, Time, Date, DateTime, ForeignKey, Index, CheckConstraint
from sqlalchemy.dialects.postgresql import ARRAY, BYTEA
from sqlalchemy.sql import func
from app.core.database import Base
from sqlalchemy.orm import relationship

class User(Base):
    __tablename__ = "app_users"
    
    user_id = Column(Integer, primary_key=True, index=True)
    device_token = Column(String(255), nullable=False)
    notification_time = Column(Time, server_default="06:00:00")
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class DailyReport(Base):
    __tablename__ = "daily_reports"
    
    report_id = Column(Integer, primary_key=True, index=True)
    report_date = Column(Date, nullable=False, unique=True, index=True)
    final_summaries_kr = Column(ARRAY(Text), nullable=False)
    top_3_sentences = Column(ARRAY(Text), nullable=False)
    market_sentiment = Column(String(10), CheckConstraint("market_sentiment IN ('어두움', '보통', '밝음')"))
    stock_theme = Column(String(100), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    images = relationship("ReportImage", back_populates="report", cascade="all, delete-orphan")
    keywords = relationship("TrendingKeyword", back_populates="report", cascade="all, delete-orphan")

class ReportImage(Base):
    __tablename__ = "report_images"
    
    image_id = Column(Integer, primary_key=True, index=True)
    report_id = Column(Integer, ForeignKey("daily_reports.report_id", ondelete="CASCADE"), nullable=False)
    referenced_sentence = Column(Text, nullable=False)
    image_data = Column(BYTEA, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    report = relationship("DailyReport", back_populates="images")

class TrendingKeyword(Base):
    __tablename__ = "trending_keywords"
    
    keyword_id = Column(Integer, primary_key=True, index=True)
    report_id = Column(Integer, ForeignKey("daily_reports.report_id", ondelete="CASCADE"), nullable=False)
    ranking = Column(Integer, nullable=False)
    keyword = Column(String(255), nullable=False)
    search_url = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    __table_args__ = (
        CheckConstraint("ranking BETWEEN 1 AND 10"),
    )
    
    report = relationship("DailyReport", back_populates="keywords")
