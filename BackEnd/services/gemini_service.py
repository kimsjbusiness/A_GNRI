import os
import re
from typing import Iterable, List

from dotenv import load_dotenv
from google import genai
from google.genai import errors

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")
FALLBACK_MODELS = ["gemini-2.0-flash", "gemini-2.0-flash-lite"]

client = genai.Client(api_key=GEMINI_API_KEY)


def _model_candidates() -> List[str]:
    candidates = [GEMINI_MODEL, *FALLBACK_MODELS]
    return list(dict.fromkeys([model for model in candidates if model]))


def _generate_text(prompt: str) -> str:
    if not GEMINI_API_KEY:
        raise RuntimeError("GEMINI_API_KEY is not configured.")

    last_error: Exception | None = None
    for model_name in _model_candidates():
        try:
            response = client.models.generate_content(model=model_name, contents=prompt)
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


def _clean_lines(text: str, limit: int | None = None) -> List[str]:
    lines = []
    for raw_line in text.splitlines():
        line = re.sub(r"^\s*(?:[-*]|\d+[\).\s-]+)\s*", "", raw_line).strip()
        if line:
            lines.append(line)
    return lines[:limit] if limit else lines


def _bulleted(texts: Iterable[str]) -> str:
    return "\n".join(f"- {text}" for text in texts if text)


def translate_to_english(texts):
    chunk_str = _bulleted(texts)
    prompt = (
        "Translate the following news headlines/descriptions to English. "
        "Preserve the meaning and return only the translated items, one per line:\n\n"
        f"{chunk_str}"
    )
    return _generate_text(prompt)


def summarize_country_news(english_text):
    prompt = (
        "Summarize the following news into exactly 3 key English sentences. "
        "Return only the 3 sentences, one per line, without bullets or numbering:\n\n"
        f"{english_text}"
    )
    return _generate_text(prompt)


def final_summary_6_sentences(all_45_sentences_text):
    prompt = (
        "Summarize the following global news points into exactly 6 key English sentences. "
        "Return only the 6 sentences, one per line, without bullets or numbering:\n\n"
        f"{all_45_sentences_text}"
    )
    return _clean_lines(_generate_text(prompt), limit=6)


def translate_6_sentences_to_korean(sentences):
    text_to_translate = "\n".join(sentences)
    prompt = (
        "Translate the following 6 sentences into natural Korean. "
        "Return only the translated sentences, one per line, without bullets or numbering:\n\n"
        f"{text_to_translate}"
    )
    return _clean_lines(_generate_text(prompt), limit=6)


def analyze_sentiment(korean_sentences):
    text = "\n".join(korean_sentences)
    prompt = (
        "Analyze the overall market sentiment of the following Korean news sentences. "
        "Respond with exactly one Korean word from these options only: 어두움, 보통, 밝음.\n\n"
        f"Sentences:\n{text}"
    )
    res = _generate_text(prompt).strip().replace("'", "").replace('"', "")
    if "밝음" in res:
        return "밝음"
    if "어두움" in res:
        return "어두움"
    return "보통"


def extract_stock_theme(korean_sentences):
    text = "\n".join(korean_sentences)
    prompt = (
        "Based on the following 6 global news sentences, choose the single stock-market theme "
        "that is most likely to have high liquidity today. Respond with exactly one short Korean "
        "theme phrase only, for example 반도체, AI, 친환경 에너지, 방산, 바이오. Do not explain.\n\n"
        f"Sentences:\n{text}"
    )
    return _generate_text(prompt).splitlines()[0].strip()
