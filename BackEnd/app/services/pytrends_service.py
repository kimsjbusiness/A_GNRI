import asyncio
from concurrent.futures import ThreadPoolExecutor
from typing import Dict, List
from urllib.parse import quote_plus

from pytrends.request import TrendReq


class PytrendsService:
    def __init__(self):
        self.pytrends = TrendReq(hl="ko-KR", tz=540)
        self.executor = ThreadPoolExecutor(max_workers=1)

    def _get_trending_searches(self) -> List[str]:
        df = self.pytrends.trending_searches(pn="south_korea")
        return df[0].dropna().astype(str).tolist()[:10]

    async def get_top_10_keywords(self) -> List[Dict[str, str]]:
        loop = asyncio.get_event_loop()
        try:
            keywords = await loop.run_in_executor(self.executor, self._get_trending_searches)
        except Exception:
            keywords = [f"테스트 키워드 {i}" for i in range(1, 11)]

        results = []
        for i, keyword in enumerate(keywords[:10]):
            search_url = f"https://www.google.com/search?q={quote_plus(f'{keyword} 뉴스')}"
            results.append(
                {
                    "ranking": i + 1,
                    "keyword": keyword,
                    "search_url": search_url,
                }
            )
        return results


pytrends_service = PytrendsService()
