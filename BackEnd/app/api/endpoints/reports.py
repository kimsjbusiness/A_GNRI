import base64
from datetime import date

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import get_db
from app.models.domain import DailyReport, TrendingKeyword, ReportImage
from app.schemas.pydantic import FullReportResponse
from app.services.pytrends_service import pytrends_service

router = APIRouter()

pipeline_status = {
    "is_running": False,
    "progress": 0,
    "status": "idle",
}


async def serialize_report(report: DailyReport, db: AsyncSession) -> dict:
    kw_stmt = (
        select(TrendingKeyword)
        .where(TrendingKeyword.report_id == report.report_id)
        .order_by(TrendingKeyword.ranking)
    )
    kw_result = await db.execute(kw_stmt)
    keywords = kw_result.scalars().all()

    img_stmt = (
        select(ReportImage)
        .where(ReportImage.report_id == report.report_id)
        .order_by(ReportImage.image_id)
    )
    img_result = await db.execute(img_stmt)
    images = img_result.scalars().all()

    return {
        "report_id": report.report_id,
        "report_date": report.report_date.isoformat(),
        "final_summaries_kr": report.final_summaries_kr,
        "top_3_sentences": report.top_3_sentences,
        "market_sentiment": report.market_sentiment,
        "stock_theme": report.stock_theme,
        "keywords": [
            {
                "ranking": keyword.ranking,
                "keyword": keyword.keyword,
                "search_url": keyword.search_url,
            }
            for keyword in keywords
        ],
        "images": [
            {
                "referenced_sentence": image.referenced_sentence,
                "image_data_base64": base64.b64encode(image.image_data).decode("ascii"),
            }
            for image in images
        ],
    }


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

@router.get("/")
async def get_report_history(db: AsyncSession = Depends(get_db)):
    stmt = select(DailyReport).order_by(DailyReport.report_date.desc())
    result = await db.execute(stmt)
    reports = result.scalars().all()

    return [
        {
            "report_date": report.report_date.isoformat(),
            "market_sentiment": report.market_sentiment,
            "summary_preview": (
                report.final_summaries_kr[0]
                if report.final_summaries_kr
                else ""
            ),
        }
        for report in reports
    ]

@router.get("/today")
async def get_today_report(db: AsyncSession = Depends(get_db)):
    stmt = select(DailyReport).order_by(DailyReport.report_date.desc()).limit(1)
    result = await db.execute(stmt)
    report = result.scalar_one_or_none()

    if not report:
        raise HTTPException(status_code=404, detail="No reports found")

    return await serialize_report(report, db)

@router.get("/today/pipeline-status")
async def get_pipeline_status():
    return pipeline_status

@router.get("/trends/realtime")
async def get_realtime_trends():
    return await pytrends_service.get_top_10_keywords()

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

@router.get("/{date_str}")
async def get_frontend_report_by_date(date_str: date, db: AsyncSession = Depends(get_db)):
    stmt = select(DailyReport).where(DailyReport.report_date == date_str)
    result = await db.execute(stmt)
    report = result.scalar_one_or_none()

    if not report:
        raise HTTPException(status_code=404, detail=f"No report found for date {date_str}")

    return await serialize_report(report, db)

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
