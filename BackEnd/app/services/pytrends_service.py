from pytrends.request import TrendReq
from typing import List, Dict
import asyncio
from concurrent.futures import ThreadPoolExecutor

class PytrendsService:
    def __init__(self):
        self.pytrends = TrendReq(hl='ko-KR', tz=540)
        self.executor = ThreadPoolExecutor(max_workers=1)

    def _get_trending_searches(self) -> List[str]:
        # Get daily search trends for South Korea
        df = self.pytrends.trending_searches(pn='south_korea')
        return df[0].tolist()[:10]

    async def get_top_10_keywords(self) -> List[Dict[str, str]]:
        """Get top 10 keywords with Google News search links."""
        loop = asyncio.get_event_loop()
        keywords = await loop.run_in_executor(self.executor, self._get_trending_searches)
        
        results = []
        for i, kw in enumerate(keywords):
            # Ranking is 1-indexed
            search_url = f"https://www.google.com/search?q={kw.replace(' ', '+')}+뉴스"
            results.append({
                "ranking": i + 1,
                "keyword": kw,
                "search_url": search_url
            })
        return results

pytrends_service = PytrendsService()
