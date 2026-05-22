from urllib.parse import quote_plus

from pytrends.request import TrendReq


def get_top_10_trends():
    """
    Get top 10 daily trending searches from Google using pytrends.
    Returns ranking, keyword, and a Google search URL for "<keyword> 뉴스".
    """
    pytrend = TrendReq(hl="ko-KR", tz=540)

    try:
        trending_df = pytrend.trending_searches(pn="south_korea")
        keywords = trending_df[0].dropna().astype(str).tolist()[:10]
    except Exception as e:
        print(f"Failed to get trends from pytrends: {e}")
        keywords = [f"테스트 키워드 {i}" for i in range(1, 11)]

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
