from sqlalchemy import Column, Integer, String, Time, DateTime, Date, ForeignKey, Enum, ARRAY, Text, text
from sqlalchemy.dialects.postgresql import BYTEA
from sqlalchemy.orm import relationship
import datetime
from database import Base

class AppUser(Base):
    __tablename__ = "app_users"

    user_id = Column(Integer, primary_key=True, index=True)
    device_token = Column(String(255), nullable=False)
    notification_time = Column(Time, server_default='06:00:00')
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

class DailyReport(Base):
    __tablename__ = "daily_reports"

    report_id = Column(Integer, primary_key=True, index=True)
    report_date = Column(Date, nullable=False, unique=True, index=True)
    final_summaries_kr = Column(ARRAY(Text), nullable=False)
    top_3_sentences = Column(ARRAY(Text), nullable=False)
    market_sentiment = Column(String(10))
    stock_theme = Column(String(100), nullable=False)
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

    images = relationship("ReportImage", back_populates="report", cascade="all, delete-orphan")
    keywords = relationship("TrendingKeyword", back_populates="report", cascade="all, delete-orphan")

class ReportImage(Base):
    __tablename__ = "report_images"

    image_id = Column(Integer, primary_key=True, index=True)
    report_id = Column(Integer, ForeignKey("daily_reports.report_id", ondelete="CASCADE"), nullable=False)
    referenced_sentence = Column(Text, nullable=False)
    image_data = Column(BYTEA, nullable=False)
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

    report = relationship("DailyReport", back_populates="images")

class TrendingKeyword(Base):
    __tablename__ = "trending_keywords"

    keyword_id = Column(Integer, primary_key=True, index=True)
    report_id = Column(Integer, ForeignKey("daily_reports.report_id", ondelete="CASCADE"), nullable=False)
    ranking = Column(Integer, nullable=False)
    keyword = Column(String(255), nullable=False)
    search_url = Column(Text, nullable=False)
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"))

    report = relationship("DailyReport", back_populates="keywords")
