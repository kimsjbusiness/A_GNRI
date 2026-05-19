from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
from app.core.database import get_db
from app.models.domain import DailyReport, TrendingKeyword, ReportImage
from app.schemas.pydantic import DailyReportSchema, FullReportResponse, TrendingKeywordSchema
from datetime import date

router = APIRouter()

@router.get("/latest", response_model=FullReportResponse)
async def get_latest_report(db: AsyncSession = Depends(get_db)):
    # Get the most recent report
    stmt = select(DailyReport).order_by(DailyReport.report_date.desc()).limit(1)
    result = await db.execute(stmt)
    report = result.scalar_one_or_none()
    
    if not report:
        raise HTTPException(status_code=404, detail="No reports found")
    
    # Get keywords
    kw_stmt = select(TrendingKeyword).where(TrendingKeyword.report_id == report.report_id).order_by(TrendingKeyword.ranking)
    kw_result = await db.execute(kw_stmt)
    keywords = kw_result.scalars().all()
    
    return {
        "report": report,
        "keywords": keywords
    }

@router.get("/history", response_model=FullReportResponse)
async def get_report_by_date(report_date: date, db: AsyncSession = Depends(get_db)):
    stmt = select(DailyReport).where(DailyReport.report_date == report_date)
    result = await db.execute(stmt)
    report = result.scalar_one_or_none()
    
    if not report:
        raise HTTPException(status_code=404, detail=f"No report found for date {report_date}")
        
    kw_stmt = select(TrendingKeyword).where(TrendingKeyword.report_id == report.report_id).order_by(TrendingKeyword.ranking)
    kw_result = await db.execute(kw_stmt)
    keywords = kw_result.scalars().all()
    
    return {
        "report": report,
        "keywords": keywords
    }

@router.get("/image/{image_id}")
async def get_report_image(image_id: int, db: AsyncSession = Depends(get_db)):
    stmt = select(ReportImage).where(ReportImage.image_id == image_id)
    result = await db.execute(stmt)
    img = result.scalar_one_or_none()
    
    if not img:
        raise HTTPException(status_code=404, detail="Image not found")
        
    return Response(content=img.image_data, media_type="image/png")

@router.get("/{report_id}/images")
async def get_report_images_info(report_id: int, db: AsyncSession = Depends(get_db)):
    stmt = select(ReportImage).where(ReportImage.report_id == report_id)
    result = await db.execute(stmt)
    images = result.scalars().all()
    
    return [{"image_id": img.image_id, "referenced_sentence": img.referenced_sentence} for img in images]
