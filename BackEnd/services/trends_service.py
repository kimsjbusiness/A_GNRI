import requests
import xml.etree.ElementTree as ET
from urllib.parse import quote_plus
from pytrends.request import TrendReq
import urllib3

# Suppress SSL verification warnings for verify=False requests
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def get_trends_via_rss():
    """
    Fallback method to fetch Google trending searches in South Korea
    using Google's official Daily Trends RSS feed.
    Uses 'requests' with SSL validation disabled (verify=False) to bypass any local host SSL configurations.
    """
    try:
        url = "https://trends.google.com/trends/trendingsearches/daily/rss?geo=KR"
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        }
        # Force fetch bypassing SSL certificate checks which frequently fail in local virtual environments
        response = requests.get(url, headers=headers, verify=False, timeout=8)
        if response.status_code == 200:
            root = ET.fromstring(response.content)
            keywords = []
            # Google Daily Trends RSS feeds title tags represent trending searches
            for item in root.findall('.//item')[:10]:
                title = item.find('title')
                if title is not None and title.text:
                    keywords.append(title.text.strip())
            if keywords:
                return keywords
            else:
                print("RSS trends elements parse failed (empty list).")
        else:
            print(f"RSS trends fetch status failed with code: {response.status_code}")
    except Exception as e:
        print(f"Failed to fetch trends via RSS backup requests: {e}")
    return []

def get_top_10_trends():
    """
    Get top 10 daily trending searches from Google.
    Tries pytrends library first, then falls back to official RSS feed parsing to prevent Mock data.
    Returns ranking, keyword, and Google search URL for "<keyword> 뉴스".
    """
    keywords = []

    # Try 1: Using pytrends library
    try:
        pytrend = TrendReq(hl="ko-KR", tz=540)
        trending_df = pytrend.trending_searches(pn="south_korea")
        keywords = trending_df[0].dropna().astype(str).tolist()[:10]
    except Exception as e:
        print(f"Primary pytrends library failed: {e}. Attempting RSS fallback...")

    # Try 2: Fallback to RSS parsing (Bypasses Google 429/CAPTCHA / SSL constraints via verify=False requests)
    if not keywords:
        keywords = get_trends_via_rss()

    # Try 3: Last resort mock data if all networks fail
    if not keywords:
        print("Both pytrends and RSS failed. Resorting to Mock placeholders.")
        keywords = [f"인기 트렌드 키워드 {i}" for i in range(1, 11)]

    results = []
    for rank, keyword in enumerate(keywords, start=1):
        search_query = f"{keyword} 뉴스"
        search_url = f"https://www.google.com/search?q={quote_plus(search_query)}"
        results.append(
            {
                "ranking": rank,
                "keyword": keyword,
                "search_url": search_url,
            }
        )

    return results
