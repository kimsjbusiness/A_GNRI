import datetime
import logging

from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from sqlalchemy import cast, String

from database import SessionLocal
from models import AppUser, DailyReport, ReportImage, TrendingKeyword
from services.fcm_service import send_push_notification
from services.gemini_service import (
    analyze_sentiment,
    extract_stock_theme,
    final_summary_6_sentences,
    summarize_country_news,
    translate_6_sentences_to_korean,
    translate_to_english,
)
from services.image_service import generate_image
from services.news_service import get_news_texts
from services.trends_service import get_top_10_trends
from utils.mmr import extract_top_sentences_mmr

logger = logging.getLogger(__name__)
scheduler = BackgroundScheduler()
_pipeline_lock = False
_pipeline_progress = 0
_pipeline_status = "대기 중"


def notify_all_users_report_ready():
    db = SessionLocal()
    try:
        users = db.query(AppUser).all()
        logger.info("Sending completion notification to %d users...", len(users))
        for user in users:
            if user.device_token:
                try:
                    send_push_notification(
                        user.device_token,
                        "A_GNRI 최신 리포트 완료",
                        "오늘의 최신 글로벌 뉴스 리포트 요약이 완성되었습니다! 지금 확인해 보세요."
                    )
                except Exception as ex:
                    logger.error("Failed to notify user token=%s: %s", user.device_token, ex)
    except Exception as e:
        logger.exception("Failed to query users for push notification")
    finally:
        db.close()


def run_daily_pipeline(force: bool = False):
    global _pipeline_lock, _pipeline_progress, _pipeline_status
    logger.info("[%s] Starting daily pipeline (force=%s)...", datetime.datetime.now(), force)
    _pipeline_lock = True
    _pipeline_progress = 5
    _pipeline_status = "글로벌 뉴스 수집을 시작합니다..."
    db = SessionLocal()
    try:
        today = datetime.date.today()
        existing = db.query(DailyReport).filter(DailyReport.report_date == today).first()
        if existing:
            if force:
                logger.info("Today's report already exists. Force flag active, deleting old report for recreation...")
                # Explicitly delete child rows first to avoid any DB foreign key integrity errors
                db.query(ReportImage).filter(ReportImage.report_id == existing.report_id).delete()
                db.query(TrendingKeyword).filter(TrendingKeyword.report_id == existing.report_id).delete()
                db.delete(existing)
                db.flush()  # Push deletions to DB buffer to release unique date constraint without intermediate commit
            else:
                logger.info("Today's report already exists. Skipping recreation.")
                _pipeline_progress = 100
                _pipeline_status = "최신 보고서 분석 완료!"
                try:
                    notify_all_users_report_ready()
                except Exception as fcm_err:
                    logger.error("FCM dispatch failed: %s", fcm_err)
                return existing

        logger.info("Fetching news...")
        news_by_country = get_news_texts()
        _pipeline_progress = 20
        _pipeline_status = "각 국가별 수집된 뉴스 번역 및 요약 중..."

        all_3_sentences = []
        for country, texts in news_by_country.items():
            if not texts:
                logger.warning("No news fetched for country=%s", country)
                continue

            english_text = translate_to_english(texts)
            summary_3 = summarize_country_news(english_text)
            all_3_sentences.append(summary_3)

        if not all_3_sentences:
            raise RuntimeError("No news text was available for summarization.")

        logger.info("Finalizing summaries...")
        _pipeline_progress = 45
        _pipeline_status = "Gemini AI 한글 보고서 최종 요약 생성 중..."
        all_45_text = "\n".join(all_3_sentences)
        final_6_en = final_summary_6_sentences(all_45_text)
        final_6_kr = translate_6_sentences_to_korean(final_6_en)

        if len(final_6_kr) != 6:
            raise RuntimeError(f"Expected 6 Korean summaries, got {len(final_6_kr)}.")

        logger.info("Extracting MMR top 3...")
        _pipeline_progress = 65
        _pipeline_status = "MMR 알고리즘 기반 핵심 3문장 추출 중..."
        top_3_kr = extract_top_sentences_mmr(final_6_kr, top_n=3)

        logger.info("Analyzing sentiment and stock theme...")
        sentiment = analyze_sentiment(final_6_kr)
        theme = extract_stock_theme(final_6_kr)

        report = DailyReport(
            report_date=today,
            final_summaries_kr=final_6_kr,
            top_3_sentences=top_3_kr,
            market_sentiment=sentiment,
            stock_theme=theme,
        )
        db.add(report)
        db.flush()

        logger.info("Generating images...")
        _pipeline_progress = 85
        _pipeline_status = "Stable Diffusion AI 뉴스 일러스트 이미지 3장 생성 중..."
        generated_image_count = 0
        for sentence in top_3_kr:
            try:
                en_prompt = translate_to_english([sentence])
                img_bytes = generate_image(en_prompt)
            except Exception:
                logger.exception("Image generation failed for sentence: %s", sentence)
                continue

            if img_bytes:
                generated_image_count += 1
                db.add(
                    ReportImage(
                        report_id=report.report_id,
                        referenced_sentence=sentence,
                        image_data=img_bytes,
                    )
                )

        if generated_image_count != 3:
            logger.warning("Expected 3 generated images, got %s. Saving report anyway.", generated_image_count)

        logger.info("Fetching trends...")
        _pipeline_progress = 95
        _pipeline_status = "실시간 구글 인기 검색어 수집 및 최종 저장 중..."
        trends = get_top_10_trends()
        if len(trends) != 10:
            raise RuntimeError(f"Expected 10 trending keywords, got {len(trends)}.")
        for trend in trends:
            db.add(
                TrendingKeyword(
                    report_id=report.report_id,
                    ranking=trend["ranking"],
                    keyword=trend["keyword"],
                    search_url=trend["search_url"],
                )
            )

        db.commit()
        db.refresh(report)
        logger.info("[%s] Daily pipeline completed successfully.", datetime.datetime.now())
        _pipeline_progress = 100
        _pipeline_status = "최신 보고서 분석 완료!"
        try:
            notify_all_users_report_ready()
        except Exception as fcm_err:
            logger.error("FCM dispatch failed: %s", fcm_err)
        return report

    except Exception:
        _pipeline_progress = 0
        _pipeline_status = "오류로 가동이 중단되었습니다."
        logger.exception("Error in daily pipeline")
        db.rollback()
        raise
    finally:
        _pipeline_lock = False
        db.close()


def check_and_send_notifications():
    now = datetime.datetime.now()
    current_time_str = now.strftime("%H:%M")

    db = SessionLocal()
    try:
        today = datetime.date.today()
        report = db.query(DailyReport).filter(DailyReport.report_date == today).first()
        if not report:
            return

        users_to_notify = (
            db.query(AppUser)
            .filter(cast(AppUser.notification_time, String).like(f"{current_time_str}%"))
            .all()
        )

        for user in users_to_notify:
            send_push_notification(
                user.device_token,
                "A_GNRI 일일 리포트",
                "오늘의 글로벌 뉴스 요약이 도착했습니다!",
            )
    finally:
        db.close()


def start_scheduler():
    scheduler.add_job(run_daily_pipeline, CronTrigger(hour=6, minute=0), replace_existing=True)
    scheduler.add_job(check_and_send_notifications, CronTrigger(second=0), replace_existing=True)
    scheduler.start()
