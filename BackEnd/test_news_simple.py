import asyncio
import os
import sys
import httpx

# backend 디렉토리를 path에 추가
sys.path.append(os.path.join(os.getcwd(), "backend"))

from app.services.news_service import news_service

async def test_news():
    print("Testing News API...")
    async with httpx.AsyncClient() as client:
        resp = await client.get("https://newsapi.org/v2/top-headlines", params={"apiKey": news_service.api_key, "country": "us"})
        print(f"Direct US fetch status: {resp.status_code}")
        if resp.status_code != 200:
            print(f"Response: {resp.text}")
    
    try:
        news = await news_service.get_all_news()
        print(f"Successfully fetched {len(news)} news articles.")
        if news:
            print(f"First article: {news[0][:100]}...")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    asyncio.run(test_news())
