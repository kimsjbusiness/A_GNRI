import os
from typing import Dict, List

import requests
from dotenv import load_dotenv

load_dotenv()

NEWS_API_KEY = os.getenv("NEWS_API_KEY")
TARGET_TOTAL_NEWS = 50

GDP_DATA = {
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

COUNTRY_QUERIES = {
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


def _article_text(article: dict) -> str:
    title = article.get("title") or ""
    description = article.get("description") or ""
    content = article.get("content") or ""
    return ". ".join(part for part in [title, description, content] if part).strip()


def _append_articles(fetched: List[str], seen: set[str], articles: List[dict], limit: int) -> None:
    for article in articles:
        text = _article_text(article)
        if text and text not in seen:
            fetched.append(text)
            seen.add(text)
        if len(fetched) >= limit:
            break


def calculate_article_counts() -> Dict[str, int]:
    total_gdp = sum(GDP_DATA.values())
    counts = {}
    allocated = 0
    for country, gdp in GDP_DATA.items():
        count = max(1, int((gdp / total_gdp) * TARGET_TOTAL_NEWS))
        counts[country] = count
        allocated += count

    top_countries = sorted(GDP_DATA.keys(), key=lambda x: GDP_DATA[x], reverse=True)
    while allocated < TARGET_TOTAL_NEWS:
        country = top_countries[(TARGET_TOTAL_NEWS - allocated - 1) % len(top_countries)]
        counts[country] += 1
        allocated += 1

    while allocated > TARGET_TOTAL_NEWS:
        for country in reversed(top_countries):
            if counts[country] > 1:
                counts[country] -= 1
                allocated -= 1
                break

    return counts


def _fetch_top_headlines(country: str, count: int, fetched: List[str], seen: set[str]) -> None:
    page = 1
    while len(fetched) < count:
        params = {
            "country": country,
            "pageSize": min(count - len(fetched), 100),
            "page": page,
            "apiKey": NEWS_API_KEY,
        }
        try:
            response = requests.get("https://newsapi.org/v2/top-headlines", params=params, timeout=20)
        except requests.RequestException:
            break

        if response.status_code != 200:
            break

        articles = response.json().get("articles", [])
        if not articles:
            break

        _append_articles(fetched, seen, articles, count)
        page += 1


def _fetch_everything(country: str, count: int, fetched: List[str], seen: set[str]) -> None:
    params = {
        "q": COUNTRY_QUERIES[country],
        "language": "en",
        "sortBy": "publishedAt",
        "pageSize": count,
        "apiKey": NEWS_API_KEY,
    }
    try:
        response = requests.get("https://newsapi.org/v2/everything", params=params, timeout=20)
    except requests.RequestException:
        return

    if response.status_code != 200:
        return

    articles = response.json().get("articles", [])
    _append_articles(fetched, seen, articles, count)


def get_450_news_texts() -> Dict[str, List[str]]:
    """
    Fetch 50 news items from the top 15 GDP countries according to GDP-based ratios.
    NewsAPI /everything is used first to keep the daily request count low; country
    top-headlines are used only when a country returns too few articles.
    """
    if not NEWS_API_KEY:
        raise RuntimeError("NEWS_API_KEY is not configured.")

    news_by_country = {}
    for country, count in calculate_article_counts().items():
        fetched: List[str] = []
        seen: set[str] = set()
        _fetch_everything(country, count, fetched, seen)
        if len(fetched) < count:
            _fetch_top_headlines(country, count, fetched, seen)
        news_by_country[country] = fetched[:count]

    return news_by_country


def get_news_texts() -> Dict[str, List[str]]:
    return get_450_news_texts()
