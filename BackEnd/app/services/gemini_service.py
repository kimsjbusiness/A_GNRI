import json
import re
from typing import Dict, List

from google import genai
from google.genai import errors

from app.core.config import settings


class GeminiService:
    def __init__(self):
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        self.primary_model = "gemini-2.5-flash"
        self.fallback_models = ["gemini-2.0-flash", "gemini-2.0-flash-lite"]

    def _model_candidates(self) -> List[str]:
        configured_model = getattr(settings, "GEMINI_MODEL", None)
        candidates = [configured_model or self.primary_model, *self.fallback_models]
        return list(dict.fromkeys([model for model in candidates if model]))

    async def _generate_with_fallback(self, prompt: str) -> str:
        if not settings.GEMINI_API_KEY:
            raise RuntimeError("GEMINI_API_KEY is not configured.")

        last_error: Exception | None = None
        for model_name in self._model_candidates():
            try:
                response = await self.client.aio.models.generate_content(
                    model=model_name,
                    contents=prompt,
                )
                text = (response.text or "").strip()
                if text:
                    return text
                last_error = RuntimeError(f"Gemini model {model_name} returned no text.")
            except errors.APIError as exc:
                last_error = exc
                if exc.code in {401, 403}:
                    raise
            except Exception as exc:
                last_error = exc

        raise RuntimeError(f"Gemini generation failed for all configured models: {last_error}")

    def _clean_lines(self, text: str, limit: int | None = None) -> List[str]:
        lines = []
        for raw_line in text.splitlines():
            line = re.sub(r"^\s*(?:[-*]|\d+[\).\s-]+)\s*", "", raw_line).strip()
            if line:
                lines.append(line)
        return lines[:limit] if limit else lines

    def _parse_json_array(self, text: str, expected_len: int | None = None) -> List[str]:
        cleaned = text.strip()
        if cleaned.startswith("```"):
            cleaned = re.sub(r"^```(?:json)?\s*|\s*```$", "", cleaned, flags=re.IGNORECASE | re.DOTALL).strip()

        try:
            parsed = json.loads(cleaned)
            if isinstance(parsed, list):
                values = [str(item).strip() for item in parsed if str(item).strip()]
                return values[:expected_len] if expected_len else values
        except json.JSONDecodeError:
            pass

        lines = self._clean_lines(text)
        return lines[:expected_len] if expected_len else lines

    async def translate_to_english(self, texts: List[str]) -> List[str]:
        if not texts:
            return []

        translated: List[str] = []
        chunk_size = 30
        for start in range(0, len(texts), chunk_size):
            chunk = texts[start : start + chunk_size]
            combined_text = "\n".join(f"{idx + 1}. {text}" for idx, text in enumerate(chunk))
            prompt = (
                "Translate the following news snippets into English. "
                "Return only a valid JSON array of translated strings in the same order. "
                "Do not include markdown or explanations.\n\n"
                f"{combined_text}"
            )
            text_out = await self._generate_with_fallback(prompt)
            parsed = self._parse_json_array(text_out, expected_len=len(chunk))
            if len(parsed) != len(chunk):
                raise RuntimeError(f"Expected {len(chunk)} translated items, got {len(parsed)}.")
            translated.extend(parsed)

        return translated

    async def summarize_by_country(self, country_news: Dict[str, List[str]]) -> List[str]:
        all_summaries: List[str] = []
        for country, news_list in country_news.items():
            if not news_list:
                continue

            combined = "\n".join(f"- {news}" for news in news_list)
            prompt = (
                f"Summarize the following news from {country} into exactly 3 concise English sentences. "
                "Return only the 3 sentences, one per line, without bullets or numbering:\n\n"
                f"{combined}"
            )
            summary_text = await self._generate_with_fallback(prompt)
            sentences = self._clean_lines(summary_text, limit=3)
            if len(sentences) != 3:
                raise RuntimeError(f"Expected 3 summary sentences for {country}, got {len(sentences)}.")
            all_summaries.extend(sentences)
        return all_summaries

    async def final_summary(self, forty_five_sentences: List[str]) -> str:
        combined = "\n".join(f"- {sentence}" for sentence in forty_five_sentences)
        prompt = (
            "Summarize the following global news points into exactly 6 clear English sentences. "
            "Return only the 6 sentences, one per line, without bullets or numbering:\n\n"
            f"{combined}"
        )
        text = await self._generate_with_fallback(prompt)
        return "\n".join(self._clean_lines(text, limit=6))

    async def translate_to_korean(self, english_text: str) -> List[str]:
        prompt = (
            "Translate these 6 English sentences into natural Korean. "
            "Return only the translated sentences, one per line, without bullets or numbering:\n\n"
            f"{english_text}"
        )
        text_out = await self._generate_with_fallback(prompt)
        return self._clean_lines(text_out, limit=6)

    async def analyze_sentiment(self, korean_sentences: List[str]) -> str:
        combined = "\n".join(korean_sentences)
        prompt = (
            "Analyze the overall market sentiment of these Korean news sentences. "
            "Return exactly one Korean word from these options only: 어두움, 보통, 밝음.\n\n"
            f"{combined}"
        )
        sentiment = await self._generate_with_fallback(prompt)
        if "밝음" in sentiment:
            return "밝음"
        if "어두움" in sentiment:
            return "어두움"
        return "보통"

    async def generate_stock_theme(self, korean_sentences: List[str]) -> str:
        combined = "\n".join(korean_sentences)
        prompt = (
            "Based on these Korean news sentences, identify the stock-market theme with the "
            "highest expected liquidity today. Return only one short theme phrase, for example "
            "반도체, AI, 친환경 에너지, 방산, 바이오. Do not explain.\n\n"
            f"{combined}"
        )
        return (await self._generate_with_fallback(prompt)).splitlines()[0].strip()


gemini_service = GeminiService()
