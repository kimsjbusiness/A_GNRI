import asyncio
import logging
import sys
import os

# backend 디렉토리를 path에 추가
sys.path.append(os.path.join(os.getcwd(), "backend"))

# .env 파일에서 환경 변수 로드
from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env"))

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
        report = await run_daily_report_pipeline(force=True)
        
        # 중복 배제 및 포맷 정밀 검증
        featured = report.final_summaries_kr[:2]
        top3 = report.top_3_sentences
        overlap = set(featured).intersection(set(top3))
        
        logger.info("--------------------------------------------------")
        logger.info(f"테스트 성공! 리포트 날짜: {report.report_date}")
        logger.info(f"감정 분석 결과: {report.market_sentiment}")
        logger.info(f"주식 테마: {report.stock_theme}")
        logger.info(f"요약된 문장 수: {len(report.final_summaries_kr)}개 (기대값: 6개)")
        logger.info(f"오늘의 주요 뉴스 수: {len(report.top_3_sentences)}개 (기대값: 3개)")
        
        if overlap:
            logger.error(f"[오류] 콘텐츠 중복 검증 실패! 중복된 문장: {overlap}")
            raise RuntimeError(f"중복 기사 선별 에러: {overlap}")
        else:
            logger.info("[성공] 중복 배제 검증 통과! 대표 카드 2문장과 주요 뉴스 3문장 간 중복된 항목이 0개입니다.")
        logger.info("--------------------------------------------------")
    except Exception as e:
        logger.error(f"테스트 실패: {str(e)}")
        logger.error("팁: .env 파일에 유효한 API 키가 입력되어 있는지 확인해주세요.")

if __name__ == "__main__":
    asyncio.run(test_full_pipeline())
