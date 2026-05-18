from sqlalchemy.ext.asyncio import AsyncSession
from datetime import date
from app.core.database import AsyncSessionLocal
from app.models.domain import DailyReport, ReportImage, TrendingKeyword
from app.services.news_service import news_service
from app.services.gemini_service import gemini_service
from app.services.mmr_service import mmr_service
from app.services.image_service import image_service
from app.services.pytrends_service import pytrends_service
import logging

logger = logging.getLogger(__name__)

async def run_daily_report_pipeline():
    """Execute the full 14-step workflow and save to database."""
    async with AsyncSessionLocal() as db:
        try:
            logger.info("Starting Daily Report Pipeline...")
            
            # 1. Fetch 450 news
            try:
                raw_news = await news_service.get_all_news()
            except Exception as e:
                logger.warning(f"News fetch failed: {e}. Using dummy news for testing.")
                raw_news = ["Global market shows stability despite inflation concerns."] * 450
            
            if not raw_news:
                logger.warning("No news fetched. Using dummy news for testing.")
                raw_news = ["Global market shows stability despite inflation concerns."] * 450
            
            # 2. Translate to English (Gemini)
            # Since news_service might already give English or titles, we proceed.
            # Step 2: "Translate all 450 news to English"
            en_news = await gemini_service.translate_to_english(raw_news)
            
            # 3. Summarize by country (15 countries * 3 = 45 sentences)
            # We need to maintain country mapping. 
            # (Simplified for now: distribute 450 items into 15 groups of 30)
            country_groups = {}
            for i, country in enumerate(news_service.gdp_data.keys()):
                country_groups[country] = en_news[i*30 : (i+1)*30]
            
            forty_five_sentences = await gemini_service.summarize_by_country(country_groups)
            
            # 4. Final summary (6 sentences EN)
            final_summary_en = await gemini_service.final_summary(forty_five_sentences)
            
            # 5. Translate to Korean (6 sentences KR)
            final_summaries_kr = await gemini_service.translate_to_korean(final_summary_en)
            
            # 6. MMR (Top 3 KR sentences)
            top_3_sentences = mmr_service.select_top_sentences(final_summaries_kr, top_n=3)
            
            # 7. Generate 3 images
            # (Using English sentences for better image generation if possible, 
            # but using top_3_sentences as requested)
            images_data = await image_service.generate_images_for_sentences(top_3_sentences)
            
            # 8. Sentiment Analysis
            sentiment = await gemini_service.analyze_sentiment(final_summaries_kr)
            
            # 9. Stock Theme
            theme = await gemini_service.generate_stock_theme(final_summaries_kr)
            
            # 10. Trending Keywords (Pytrends)
            trending_data = await pytrends_service.get_top_10_keywords()
            
            # --- Save to Database ---
            
            report = DailyReport(
                report_date=date.today(),
                final_summaries_kr=final_summaries_kr,
                top_3_sentences=top_3_sentences,
                market_sentiment=sentiment,
                stock_theme=theme
            )
            db.add(report)
            await db.flush() # Get report_id
            
            # Save Images
            for i, img_bytes in enumerate(images_data):
                img_obj = ReportImage(
                    report_id=report.report_id,
                    referenced_sentence=top_3_sentences[i],
                    image_data=img_bytes
                )
                db.add(img_obj)
                
            # Save Trending Keywords
            for kw_item in trending_data:
                kw_obj = TrendingKeyword(
                    report_id=report.report_id,
                    ranking=kw_item["ranking"],
                    keyword=kw_item["keyword"],
                    search_url=kw_item["search_url"]
                )
                db.add(kw_obj)
            
            await db.commit()
            logger.info(f"Successfully created daily report for {date.today()}")
            
            return report
            
        except Exception as e:
            await db.rollback()
            logger.error(f"Pipeline failed: {str(e)}")
            raise e
