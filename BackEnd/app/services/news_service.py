import math
from typing import Dict, List

import httpx

from app.core.config import settings


class NewsService:
    def __init__(self):
        self.api_key = settings.NEWS_API_KEY
        self.top_headlines_url = "https://newsapi.org/v2/top-headlines"
        self.everything_url = "https://newsapi.org/v2/everything"
        self.gdp_data = {
            "us": 27.97,
            "cn": 18.56,
            "de": 4.70,
            "jp": 4.29,
            "in": 4.11,
            "gb": 3.59,
            "fr": 3.18,
            "it": 2.30,
            "br": 2.27,
            "ca": 2.24,
            "ru": 1.90,
            "mx": 1.81,
            "kr": 1.78,
            "au": 1.74,
            "es": 1.68,
        }
        self.country_queries = {
            "us": "United States",
            "cn": "China",
            "de": "Germany",
            "jp": "Japan",
            "in": "India",
            "gb": "United Kingdom",
            "fr": "France",
            "it": "Italy",
            "br": "Brazil",
            "ca": "Canada",
            "ru": "Russia",
            "mx": "Mexico",
            "au": "Australia",
            "kr": "South Korea",
            "es": "Spain",
        }
        self.total_gdp = sum(self.gdp_data.values())
        self.target_total = 50

    def calculate_article_counts(self) -> Dict[str, int]:
        counts = {}
        allocated = 0
        for country, gdp in self.gdp_data.items():
            count = max(1, math.floor((gdp / self.total_gdp) * self.target_total))
            counts[country] = count
            allocated += count

        top_countries = sorted(self.gdp_data.keys(), key=lambda x: self.gdp_data[x], reverse=True)
        while allocated < self.target_total:
            country = top_countries[(self.target_total - allocated - 1) % len(top_countries)]
            counts[country] += 1
            allocated += 1

        while allocated > self.target_total:
            for country in reversed(top_countries):
                if counts[country] > 1:
                    counts[country] -= 1
                    allocated -= 1
                    break

        return counts

    def _article_text(self, article: dict) -> str:
        title = article.get("title") or ""
        description = article.get("description") or ""
        content = article.get("content") or ""
        return ". ".join(part for part in [title, description, content] if part).strip()

    def _append_articles(self, fetched: List[str], seen: set[str], articles: List[dict], limit: int) -> None:
        for article in articles:
            text = self._article_text(article)
            if text and text not in seen:
                fetched.append(text)
                seen.add(text)
            if len(fetched) >= limit:
                break

    async def _fetch_top_headlines(
        self,
        client: httpx.AsyncClient,
        country_code: str,
        count: int,
        fetched: List[str],
        seen: set[str],
    ) -> None:
        page = 1
        while len(fetched) < count:
            params = {
                "apiKey": self.api_key,
                "country": country_code,
                "pageSize": min(count - len(fetched), 100),
                "page": page,
            }
            response = await client.get(self.top_headlines_url, params=params)
            if response.status_code != 200:
                break

            articles = response.json().get("articles", [])
            if not articles:
                break

            self._append_articles(fetched, seen, articles, count)
            page += 1

    async def _fetch_everything(
        self,
        client: httpx.AsyncClient,
        country_code: str,
        count: int,
        fetched: List[str],
        seen: set[str],
    ) -> None:
        params = {
            "apiKey": self.api_key,
            "q": self.country_queries[country_code],
            "language": "en",
            "sortBy": "publishedAt",
            "pageSize": count,
        }
        response = await client.get(self.everything_url, params=params)
        if response.status_code != 200:
            return

        articles = response.json().get("articles", [])
        self._append_articles(fetched, seen, articles, count)

    async def fetch_news_by_country(self, client: httpx.AsyncClient, country_code: str, count: int) -> List[str]:
        fetched: List[str] = []
        seen: set[str] = set()
        await self._fetch_everything(client, country_code, count, fetched, seen)
        if len(fetched) < count:
            await self._fetch_top_headlines(client, country_code, count, fetched, seen)
        return fetched[:count]

    async def get_all_news_by_country(self) -> Dict[str, List[str]]:
        if not self.api_key:
            raise RuntimeError("NEWS_API_KEY is not configured.")

        counts = self.calculate_article_counts()
        async with httpx.AsyncClient(timeout=30.0) as client:
            result = {}
            for country, count in counts.items():
                result[country] = await self.fetch_news_by_country(client, country, count)
            return result

    async def get_all_news(self) -> List[str]:
        news_by_country = await self.get_all_news_by_country()
        return [item for items in news_by_country.values() for item in items]


news_service = NewsService()
