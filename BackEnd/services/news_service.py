import os
import requests
from dotenv import load_dotenv

load_dotenv()

NEWS_API_KEY = os.getenv("NEWS_API_KEY")

# Top 15 GDP countries and their ratio of 450 news
COUNTRY_COUNTS = {
    "us": 120,
    "cn": 80,
    "de": 30,
    "jp": 30,
    "in": 30,
    "gb": 25,
    "fr": 20,
    "it": 15,
    "br": 15,
    "ca": 15,
    "ru": 15,
    "mx": 15,
    "au": 15,
    "kr": 15,
    "es": 10,
}

def get_450_news_texts():
    """
    Fetch news from top 15 GDP countries based on ratios.
    Total should be around 450.
    Returns a dictionary mapping country to list of texts or just a list.
    We need it per country for the 3-sentence summary later.
    """
    news_by_country = {}
    for country, count in COUNTRY_COUNTS.items():
        fetched = []
        page = 1
        while len(fetched) < count:
            url = f"https://newsapi.org/v2/top-headlines"
            params = {
                "country": country,
                "pageSize": min(count - len(fetched), 100),
                "page": page,
                "apiKey": NEWS_API_KEY
            }
            res = requests.get(url, params=params)
            if res.status_code == 200:
                articles = res.json().get("articles", [])
                if not articles:
                    break
                for article in articles:
                    title = article.get("title") or ""
                    description = article.get("description") or ""
                    text = f"{title}. {description}".strip()
                    if text and text != ".":
                        fetched.append(text)
                page += 1
            else:
                break
        news_by_country[country] = fetched[:count]
        
    return news_by_country
