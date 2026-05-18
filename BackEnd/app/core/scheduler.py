from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from app.services.report_pipeline import run_daily_report_pipeline
from app.core.database import AsyncSessionLocal
from app.models.domain import User
from sqlalchemy import select
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

scheduler = AsyncIOScheduler()

async def scheduled_report_job():
    """Main job executed at 06:00."""
    try:
        await run_daily_report_pipeline()
    except Exception as e:
        logger.error(f"Scheduled report job failed: {e}")

async def send_user_notifications():
    """Job to check and send notifications based on user preferences."""
    now = datetime.now().time()
    # Check users whose notification_time is close to 'now'
    # This job should run every minute or so.
    async with AsyncSessionLocal() as db:
        stmt = select(User).where(User.notification_time <= now) # Simplified logic
        result = await db.execute(stmt)
        users = result.scalars().all()
        
        for user in users:
            # logic to send FCM push notification
            # logger.info(f"Sending notification to user {user.user_id}")
            pass

def start_scheduler():
    # Run pipeline every day at 06:00
    scheduler.add_job(
        scheduled_report_job,
        CronTrigger(hour=6, minute=0),
        id="daily_report_job",
        replace_existing=True
    )
    
    # Run notification checker every minute
    scheduler.add_job(
        send_user_notifications,
        "interval",
        minutes=1,
        id="notification_job",
        replace_existing=True
    )
    
    scheduler.start()
    logger.info("Scheduler started.")

def stop_scheduler():
    scheduler.shutdown()
    logger.info("Scheduler stopped.")
