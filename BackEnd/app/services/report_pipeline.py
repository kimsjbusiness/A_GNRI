import logging
from datetime import date

from sqlalchemy import select

from app.core.database import AsyncSessionLocal
from app.models.domain import DailyReport, ReportImage, TrendingKeyword
from app.services.gemini_service import gemini_service
from app.services.image_service import image_service
from app.services.mmr_service import mmr_service
from app.services.news_service import news_service
from app.services.pytrends_service import pytrends_service

logger = logging.getLogger(__name__)


async def run_daily_report_pipeline(force: bool = False, progress_callback=None):
    """Execute the full daily report workflow and save it atomically."""
    def report_progress(progress: int, status: str) -> None:
        if progress_callback:
            progress_callback(progress, status)

    async with AsyncSessionLocal() as db:
        try:
            today = date.today()
            existing_result = await db.execute(
                select(DailyReport).where(DailyReport.report_date == today)
            )
            existing_report = existing_result.scalar_one_or_none()
            if existing_report:
                if not force:
                    logger.info("Daily report for %s already exists.", today)
                    report_progress(100, "최신 리포트가 이미 생성되어 있습니다.")
                    return existing_report

                logger.info("Deleting existing daily report for forced refresh: %s", today)
                report_progress(5, "기존 리포트를 삭제하고 최신화를 준비합니다...")
                await db.delete(existing_report)
                await db.flush()

            logger.info("Starting daily report pipeline...")
            report_progress(10, "글로벌 뉴스 수집을 시작합니다...")

            news_by_country = await news_service.get_all_news_by_country()
            total_news = sum(len(items) for items in news_by_country.values())
            if total_news == 0:
                raise RuntimeError("No news articles were fetched from News API.")

            report_progress(20, "각 국가별 수집 뉴스 번역을 진행 중입니다...")
            translated_by_country = {}
            for country, news_items in news_by_country.items():
                if not news_items:
                    raise RuntimeError(f"No news articles were fetched for country={country}.")
                translated_by_country[country] = await gemini_service.translate_to_english(news_items)

            report_progress(40, "국가별 뉴스 요약을 생성 중입니다...")
            forty_five_sentences = await gemini_service.summarize_by_country(translated_by_country)
            if len(forty_five_sentences) != 45:
                raise RuntimeError(f"Expected 45 country summary sentences, got {len(forty_five_sentences)}.")

            report_progress(55, "최종 한글 리포트 요약을 생성 중입니다...")
            final_summary_en = await gemini_service.final_summary(forty_five_sentences)
            final_summaries_kr = await gemini_service.translate_to_korean(final_summary_en)
            if len(final_summaries_kr) != 6:
                raise RuntimeError(f"Expected 6 Korean final summaries, got {len(final_summaries_kr)}.")

            report_progress(65, "MMR 기반 핵심 3문장을 추출 중입니다...")
            top_3_sentences = mmr_service.select_top_sentences(final_summaries_kr, top_n=3)
            if len(top_3_sentences) != 3:
                raise RuntimeError(f"Expected 3 MMR sentences, got {len(top_3_sentences)}.")

            report_progress(75, "시장 분위기와 주식 테마를 분석 중입니다...")
            sentiment = await gemini_service.analyze_sentiment(final_summaries_kr)
            theme = await gemini_service.generate_stock_theme(final_summaries_kr)
            image_records = []
            try:
                image_prompts = await gemini_service.translate_to_english(top_3_sentences)
            except Exception:
                logger.exception("Image prompt translation failed. Skipping image generation.")
                    image_prompts = []

            report_progress(85, "AI 뉴스 일러스트 이미지를 생성 중입니다...")
            for sentence, prompt in zip(top_3_sentences, image_prompts):
                try:
                    img_bytes = await image_service.generate_image(prompt)
                except Exception:
                    logger.exception("Image generation failed for sentence: %s", sentence)
                    continue

                if img_bytes:
                    image_records.append((sentence, img_bytes))

            if len(image_records) != 3:
                logger.warning("Expected 3 generated images, got %s. Saving report anyway.", len(image_records))

            report_progress(95, "실시간 인기 검색어 수집 및 최종 저장 중입니다...")
            trending_data = await pytrends_service.get_top_10_keywords()
            if len(trending_data) != 10:
                raise RuntimeError(f"Expected 10 trending keywords, got {len(trending_data)}.")

            report = DailyReport(
                report_date=today,
                final_summaries_kr=final_summaries_kr,
                top_3_sentences=top_3_sentences,
                market_sentiment=sentiment,
                stock_theme=theme,
            )
            db.add(report)
            await db.flush()

            for sentence, img_bytes in image_records:
                db.add(
                    ReportImage(
                        report_id=report.report_id,
                        referenced_sentence=sentence,
                        image_data=img_bytes,
                    )
                )

            for kw_item in trending_data:
                db.add(
                    TrendingKeyword(
                        report_id=report.report_id,
                        ranking=kw_item["ranking"],
                        keyword=kw_item["keyword"],
                        search_url=kw_item["search_url"],
                    )
                )

            await db.commit()
            logger.info("Successfully created daily report for %s.", today)
            report_progress(100, "최신 리포트 분석이 완료되었습니다.")
            return report

        except Exception:
            await db.rollback()
            logger.exception("Pipeline failed")
            raise
