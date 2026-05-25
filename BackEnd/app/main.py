import asyncio
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.api.endpoints.reports import pipeline_status
from app.api.router import api_router
from app.core.database import engine, Base
from app.core.scheduler import start_scheduler, stop_scheduler
from app.services.report_pipeline import run_daily_report_pipeline

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Create tables if they don't exist
    logger.info("Creating database tables...")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    # Start Scheduler
    start_scheduler()
    
    yield
    
    # Shutdown: Stop Scheduler
    stop_scheduler()

app = FastAPI(
    title="A_GNRI Backend",
    description="Daily News Summary and Market Analysis API",
    version="1.0.0",
    lifespan=lifespan
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Router
app.include_router(api_router, prefix="/api")
app.include_router(api_router)

@app.get("/")
async def root():
    return {"message": "A_GNRI API is running", "status": "ok"}

async def _run_pipeline_with_status():
    def update_progress(progress: int, status: str) -> None:
        pipeline_status.update({"progress": progress, "status": status})

    pipeline_status.update(
        {
            "is_running": True,
            "progress": 5,
            "status": "최신화 작업을 준비합니다...",
        }
    )
    try:
        await run_daily_report_pipeline(
            force=True,
            progress_callback=update_progress,
        )
        pipeline_status.update(
            {
                "is_running": False,
                "progress": 100,
                "status": "최신 리포트 분석이 완료되었습니다.",
            }
        )
    except Exception as exc:
        logger.exception("Manual report pipeline failed")
        pipeline_status.update(
            {
                "is_running": False,
                "progress": 0,
                "status": f"최신화 작업이 실패했습니다: {exc}",
            }
        )

@app.post("/api/test-trigger-pipeline")
@app.post("/test-trigger-pipeline")
async def trigger_pipeline():
    if pipeline_status["is_running"]:
        raise HTTPException(status_code=409, detail="Pipeline is already running")

    asyncio.create_task(_run_pipeline_with_status())
    return {"message": "Pipeline started"}
