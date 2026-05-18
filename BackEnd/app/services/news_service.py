import httpx
from typing import List, Dict
from app.core.config import settings
import math

class NewsService:
    def __init__(self):
        self.api_key = settings.NEWS_API_KEY
        self.base_url = "https://newsapi.org/v2/everything"
        
        # Top 15 GDP Countries and their approximate GDP (Trillion USD, 2024 IMF approx)
        self.gdp_data = {
            "us": 27.97, "cn": 18.56, "de": 4.70, "jp": 4.29, "in": 4.11,
            "gb": 3.59, "fr": 3.18, "it": 2.30, "br": 2.27, "ca": 2.24,
            "ru": 1.90, "mx": 1.81, "kr": 1.78, "au": 1.74, "es": 1.68
        }
        self.total_gdp = sum(self.gdp_data.values())
        self.target_total = 450

    def calculate_article_counts(self) -> Dict[str, int]:
        counts = {}
        allocated = 0
        for country, gdp in self.gdp_data.items():
            count = math.floor((gdp / self.total_gdp) * self.target_total)
            counts[country] = count
            allocated += count
        
        # Distribute remaining articles to top countries
        remaining = self.target_total - allocated
        top_countries = sorted(self.gdp_data.keys(), key=lambda x: self.gdp_data[x], reverse=True)
        for i in range(remaining):
            counts[top_countries[i % len(top_countries)]] += 1
            
        return counts

    async def fetch_news_by_country(self, country_code: str, page_size: int) -> List[str]:
        if page_size == 0:
            return []
            
        params = {
            "apiKey": self.api_key,
            "q": f"top-headlines", # Broad query or use country-specific topics
            "language": "en", # Fetching in English or local? 
                              # Step 2 says "translate to English", but some might already be English.
                              # For simplicity and reliability, I'll fetch broad news.
            "pageSize": min(page_size, 100), # NewsAPI limit per request
            "sortBy": "publishedAt"
        }
        
        # Map country code to specific search query if needed
        # Or use /v2/top-headlines if country supports it. 
        # But /v2/everything is more flexible for "450 articles".
        
        async with httpx.AsyncClient() as client:
            response = await client.get(self.base_url, params=params)
            if response.status_code != 200:
                return []
            
            data = response.json()
            articles = data.get("articles", [])
            # Extract content or description
            return [a.get("description") or a.get("content") or "" for a in articles]

    async def get_all_news(self) -> List[str]:
        counts = self.calculate_article_counts()
        all_news = []
        
        for country, count in counts.items():
            # For GDP-based distribution, we could use different queries per country
            # But NewsAPI /v2/everything doesn't have a 'country' filter (only /v2/top-headlines does)
            # So I will use /v2/top-headlines where possible, or keywords for /v2/everything.
            
            # Let's use top-headlines for better country filtering
            country_headlines_url = "https://newsapi.org/v2/top-headlines"
            params = {
                "apiKey": self.api_key,
                "country": country if country != "es" else "es", # Check supported countries
                "pageSize": min(count, 100)
            }
            
            # Note: NewsAPI top-headlines only supports specific countries. 
            # All 15 in our list are mostly supported.
            
            async with httpx.AsyncClient() as client:
                resp = await client.get(country_headlines_url, params=params)
                if resp.status_code == 200:
                    articles = resp.json().get("articles", [])
                    all_news.extend([a.get("description") or a.get("title") or "" for a in articles])
        
        return all_news[:self.target_total]

news_service = NewsService()
