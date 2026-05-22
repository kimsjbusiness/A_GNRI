import base64
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
import datetime
from contextlib import asynccontextmanager

import models, schemas
from database import engine, get_db
from scheduler import start_scheduler, run_daily_pipeline

models.Base.metadata.create_all(bind=engine)

@asynccontextmanager
async def lifespan(app: FastAPI):
    start_scheduler()
    yield

app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/users", response_model=schemas.AppUserResponse)
def create_user(user: schemas.AppUserCreate, db: Session = Depends(get_db)):
    db_user = db.query(models.AppUser).filter(models.AppUser.device_token == user.device_token).first()
    if db_user:
        if user.notification_time:
            db_user.notification_time = user.notification_time
            db.commit()
            db.refresh(db_user)
        return db_user
    
    db_user = models.AppUser(
        device_token=user.device_token,
        notification_time=user.notification_time if user.notification_time else "06:00:00"
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def format_report_response(report):
    images = []
    for img in report.images:
        b64_str = base64.b64encode(img.image_data).decode('utf-8')
        images.append({
            "referenced_sentence": img.referenced_sentence,
            "image_data_base64": b64_str
        })
    
    return {
        "report_id": report.report_id,
        "report_date": report.report_date,
        "final_summaries_kr": report.final_summaries_kr,
        "top_3_sentences": report.top_3_sentences,
        "market_sentiment": report.market_sentiment,
        "stock_theme": report.stock_theme,
        "keywords": [
            {
                "ranking": k.ranking,
                "keyword": k.keyword,
                "search_url": k.search_url
            } for k in report.keywords
        ],
        "images": images
    }

@app.get("/reports/today", response_model=schemas.DailyReportResponse)
def get_today_report(db: Session = Depends(get_db)):
    today = datetime.date.today()
    report = db.query(models.DailyReport).filter(models.DailyReport.report_date == today).first()
    if not report:
        raise HTTPException(status_code=404, detail="Today's report not generated yet")
    
    return format_report_response(report)

@app.get("/reports/{date_str}", response_model=schemas.DailyReportResponse)
def get_past_report(date_str: str, db: Session = Depends(get_db)):
    try:
        query_date = datetime.datetime.strptime(date_str, "%Y-%m-%d").date()
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD")
        
    report = db.query(models.DailyReport).filter(models.DailyReport.report_date == query_date).first()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found for this date")
        
    return format_report_response(report)

@app.post("/test-trigger-pipeline")
def trigger_pipeline(db: Session = Depends(get_db)):
    """
    For testing purposes to run the pipeline manually.
    """
    import threading
    t = threading.Thread(target=run_daily_pipeline)
    t.start()
    return {"message": "Pipeline triggered in background"}
