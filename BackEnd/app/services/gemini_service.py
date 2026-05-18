from google import genai
from typing import List, Dict, Tuple
from app.core.config import settings

class GeminiService:
    def __init__(self):
        # 1. 전역 설정이 아닌, 클라이언트 객체(Client Object)를 생성하는 방식으로 변경되었습니다.
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        self.primary_model = 'gemini-2.0-flash-lite'
        self.fallback_models = ['gemini-2.0-flash', 'gemini-pro-latest']

    async def _generate_with_fallback(self, prompt: str) -> str:
        """Attempt generation with free models only."""
        try:
            # 2. 비동기 호출을 위해 client.aio.models.generate_content를 사용합니다.
            response = await self.client.aio.models.generate_content(
                model=self.primary_model,
                contents=prompt
            )
            return response.text.strip()
        except Exception as e:
            if "not found" in str(e).lower():
                # Only try variations of the free 'flash' model
                for fallback in self.fallback_models:
                    try:
                        response = await self.client.aio.models.generate_content(
                            model=fallback,
                            contents=prompt
                        )
                        return response.text.strip()
                    except:
                        continue
            raise e

    async def translate_to_english(self, texts: List[str]) -> List[str]:
        combined_text = "\n---\n".join(texts)
        prompt = f"Translate the following news snippets into English. Separate each with '---':\n\n{combined_text}"
        
        text_out = await self._generate_with_fallback(prompt)
        translated = text_out.split("---")
        return [t.strip() for t in translated if t.strip()]

    async def summarize_by_country(self, country_news: Dict[str, List[str]]) -> List[str]:
        all_summaries = []
        for country, news_list in country_news.items():
            combined = "\n".join(news_list)
            prompt = f"Summarize the following news from {country} into exactly 3 concise English sentences:\n\n{combined}"
            all_summaries.append(await self._generate_with_fallback(prompt))
        return all_summaries

    async def final_summary(self, forty_five_sentences: List[str]) -> str:
        combined = "\n".join(forty_five_sentences)
        prompt = f"Summarize the following 45 sentences into exactly 6 clear and insightful English sentences:\n\n{combined}"
        return await self._generate_with_fallback(prompt)

    async def translate_to_korean(self, english_text: str) -> List[str]:
        prompt = f"Translate these 6 English sentences into natural Korean. Output them as a list separated by newlines:\n\n{english_text}"
        text_out = await self._generate_with_fallback(prompt)
        lines = text_out.split("\n")
        return [l.strip() for l in lines if l.strip()][:6]

    async def analyze_sentiment(self, korean_sentences: List[str]) -> str:
        combined = "\n".join(korean_sentences)
        prompt = f"Analyze the overall market sentiment of these sentences. Return only one word from: '어두움', '보통', '밝음':\n\n{combined}"
        sentiment = await self._generate_with_fallback(prompt)
        if "밝음" in sentiment: return "밝음"
        if "어두움" in sentiment: return "어두움"
        return "보통"

    async def generate_stock_theme(self, korean_sentences: List[str]) -> str:
        combined = "\n".join(korean_sentences)
        prompt = f"Based on these sentences, identify the stock market theme with the highest expected liquidity. Return only the theme name (e.g., '반도체', '이차전지'):\n\n{combined}"
        return await self._generate_with_fallback(prompt)

gemini_service = GeminiService()