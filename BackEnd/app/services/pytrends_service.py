import asyncio
from concurrent.futures import ThreadPoolExecutor
from typing import Dict, List
from urllib.parse import quote_plus

try:
    from pytrends.request import TrendReq
except ImportError:
    TrendReq = None


class PytrendsService:
    def __init__(self):
        try:
            self.pytrends = TrendReq(hl="ko-KR", tz=540) if TrendReq else None
        except Exception:
            self.pytrends = None
        self.executor = ThreadPoolExecutor(max_workers=1)

    def _get_trending_searches(self) -> List[str]:
        if not self.pytrends:
            raise RuntimeError("Pytrends is not initialized.")
        df = self.pytrends.trending_searches(pn="south_korea")
        return df[0].dropna().astype(str).tolist()[:10]

    async def get_top_10_keywords(self, news_texts: List[str] = None) -> List[Dict[str, str]]:
        """
        Generate top 10 anticipated search keywords.
        Uses Gemini API to analyze current news or general trends for higher reliability.
        """
        from app.services.gemini_service import gemini_service
        
        if not news_texts:
            try:
                from app.services.news_service import news_service
                news_texts = await news_service.get_all_news()
            except Exception:
                pass

        if news_texts:
            combined = "\n".join(f"- {text[:300]}" for text in news_texts[:30])
            prompt = (
                "Based on the following global news summaries of today, identify the top 10 most "
                "anticipated real-time search keywords (실시간 인기 검색어) that Korean users are most "
                "likely to search for today on portal sites. Focus on high-interest political, "
                "economic, technological, or social keywords related to these events.\n\n"
                "Return ONLY a valid JSON array of exactly 10 strings, representing the keywords. "
                "Do not include markdown, explanations, or numbering. Example: ['keyword1', 'keyword2', ...]\n\n"
                f"{combined}"
            )
        else:
            prompt = (
                "Identify the top 10 most anticipated real-time search keywords (실시간 인기 검색어) in "
                "South Korea today. Focus on high-interest investment, economic, technological, or "
                "social hot topics.\n\n"
                "Return ONLY a valid JSON array of exactly 10 strings, representing the keywords. "
                "Do not include markdown, explanations, or numbering. Example: ['keyword1', 'keyword2', ...]"
            )

        keywords = []
        try:
            response_text = await gemini_service._generate_with_fallback(prompt)
            keywords = gemini_service._parse_json_array(response_text, expected_len=10)
        except Exception:
            pass

        # Fallback to pytrends if Gemini fails completely
        if not keywords and self.pytrends:
            try:
                loop = asyncio.get_event_loop()
                keywords = await loop.run_in_executor(self.executor, self._get_trending_searches)
            except Exception:
                pass

        # Final default fallback if all else fails
        if not keywords:
            keywords = [
                "인공지능",
                "반도체",
                "미국 증시",
                "금리 인하",
                "전기차",
                "지정학적 리스크",
                "빅테크",
                "신재생 에너지",
                "가상자산",
                "로봇 산업",
            ]

        # Ensure we have exactly 10 keywords
        if len(keywords) < 10:
            for i in range(len(keywords) + 1, 11):
                keywords.append(f"이슈 키워드 {i}")

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
