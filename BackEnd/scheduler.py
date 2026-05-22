import datetime
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from sqlalchemy.orm import Session
from sqlalchemy import cast, String

from database import SessionLocal
from models import DailyReport, ReportImage, TrendingKeyword, AppUser
from services.news_service import get_450_news_texts
from services.gemini_service import (
    translate_to_english,
    summarize_country_news,
    final_summary_6_sentences,
    translate_6_sentences_to_korean,
    analyze_sentiment,
    extract_stock_theme
)
from services.image_service import generate_image
from services.trends_service import get_top_10_trends
from services.fcm_service import send_push_notification
from utils.mmr import extract_top_sentences_mmr

def run_daily_pipeline():
    print(f"[{datetime.datetime.now()}] Starting daily pipeline...")
    db = SessionLocal()
    try:
        today = datetime.date.today()
        existing = db.query(DailyReport).filter(DailyReport.report_date == today).first()
        if existing:
            print("Today's report already generated.")
            return

        print("Fetching news...")
        news_by_country = get_450_news_texts()
        
        all_3_sentences = []
        for country, texts in news_by_country.items():
            if not texts:
                continue
            # Chunking to avoid too large payloads, but normally 15-120 short headlines is fine
            english_texts_chunk = translate_to_english(texts)
            summary_3 = summarize_country_news(english_texts_chunk)
            all_3_sentences.append(summary_3)
            
        all_45_text = "\n".join(all_3_sentences)
        
        print("Finalizing summaries...")
        final_6_en = final_summary_6_sentences(all_45_text)
        final_6_kr = translate_6_sentences_to_korean(final_6_en)
        
        print("Extracting MMR top 3...")
        top_3_kr = extract_top_sentences_mmr(final_6_kr, top_n=3)
        
        print("Analyzing sentiment and themes...")
        sentiment = analyze_sentiment(final_6_kr)
        theme = extract_stock_theme(final_6_kr)
        
        report = DailyReport(
            report_date=today,
            final_summaries_kr=final_6_kr,
            top_3_sentences=top_3_kr,
            market_sentiment=sentiment,
            stock_theme=theme
        )
        db.add(report)
        db.commit()
        db.refresh(report)
        
        print("Generating images...")
        for sentence in top_3_kr:
            # Translate Korean sentence to English for SDXL prompt
            en_prompt = translate_to_english([sentence])
            img_bytes = generate_image(en_prompt)
            if img_bytes:
                img_record = ReportImage(
                    report_id=report.report_id,
                    referenced_sentence=sentence,
                    image_data=img_bytes
                )
                db.add(img_record)
                
        print("Fetching trends...")
        trends = get_top_10_trends()
        for t in trends:
            kw_record = TrendingKeyword(
                report_id=report.report_id,
                ranking=t['ranking'],
                keyword=t['keyword'],
                search_url=t['search_url']
            )
            db.add(kw_record)
            
        db.commit()
        print(f"[{datetime.datetime.now()}] Daily pipeline completed successfully.")

    except Exception as e:
        print(f"Error in daily pipeline: {e}")
        db.rollback()
    finally:
        db.close()


def check_and_send_notifications():
    """
    Checks if current time matches any user's notification_time and sends push notification.
    """
    now = datetime.datetime.now()
    current_time_str = now.strftime("%H:%M")
    
    db = SessionLocal()
    try:
        today = datetime.date.today()
        report = db.query(DailyReport).filter(DailyReport.report_date == today).first()
        if not report:
            return
            
        users_to_notify = db.query(AppUser).filter(
            cast(AppUser.notification_time, String).like(f"{current_time_str}%")
        ).all()
        
        for user in users_to_notify:
            send_push_notification(
                user.device_token,
                "A_GNRI 일일 리포트",
                "오늘의 글로벌 뉴스 요약이 도착했습니다!"
            )
    finally:
        db.close()


scheduler = BackgroundScheduler()

def start_scheduler():
    # 06:00 AM pipeline
    scheduler.add_job(run_daily_pipeline, CronTrigger(hour=6, minute=0))
    # Every minute notification check
    scheduler.add_job(check_and_send_notifications, CronTrigger(second=0))
    scheduler.start()
