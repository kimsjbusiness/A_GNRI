import asyncio
import logging
import sys
import os

# backend 디렉토리를 path에 추가
sys.path.append(os.path.join(os.getcwd(), "backend"))

# .env 로드를 위해 환경 변수 설정
os.environ["DATABASE_URL"] = "postgresql+asyncpg://dbadmin:qlalfqjsgh1234@localhost:25725/Main"

from app.services.report_pipeline import run_daily_report_pipeline
from app.core.database import engine, Base

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("TestRunner")

async def test_full_pipeline():
    """전체 리포트 생성 파이프라인 수동 실행 테스트"""
    logger.info("테스트 시작: 데이터베이스 테이블 생성 확인 중...")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    logger.info("파이프라인 실행 중... (외부 API 호출로 인해 시간이 소요될 수 있습니다)")
    try:
        report = await run_daily_report_pipeline()
        logger.info("--------------------------------------------------")
        logger.info(f"테스트 성공! 리포트 날짜: {report.report_date}")
        logger.info(f"감정 분석 결과: {report.market_sentiment}")
        logger.info(f"주식 테마: {report.stock_theme}")
        logger.info(f"요약된 문장 수: {len(report.final_summaries_kr)}개")
        logger.info("--------------------------------------------------")
    except Exception as e:
        logger.error(f"테스트 실패: {str(e)}")
        logger.error("팁: .env 파일에 유효한 API 키가 입력되어 있는지 확인해주세요.")

if __name__ == "__main__":
    asyncio.run(test_full_pipeline())
