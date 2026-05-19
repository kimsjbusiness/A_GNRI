from pytrends.request import TrendReq

def get_top_10_trends():
    """
    Get top 10 daily trending searches from Google using pytrends.
    Returns list of dicts with ranking, keyword, and search_url.
    """
    pytrend = TrendReq(hl='ko-KR', tz=540) # Korea Timezone
    
    try:
        trending_df = pytrend.trending_searches(pn='south_korea')
        keywords = trending_df[0].tolist()[:10]
    except Exception as e:
        print(f"Failed to get trends from pytrends: {e}")
        keywords = ["테스트 키워드 " + str(i) for i in range(1, 11)]
    
    results = []
    for rank, kw in enumerate(keywords, start=1):
        search_query = f"{kw} 뉴스"
        search_url = f"https://www.google.com/search?q={search_query.replace(' ', '+')}"
        
        results.append({
            "ranking": rank,
            "keyword": kw,
            "search_url": search_url
        })
        
    return results
