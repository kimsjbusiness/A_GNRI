import os
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
genai.configure(api_key=GEMINI_API_KEY)

MODEL_NAME = "gemini-pro"

def translate_to_english(texts):
    model = genai.GenerativeModel(MODEL_NAME)
    chunk_str = "\n".join([f"- {t}" for t in texts])
    prompt = f"Translate the following news headlines/descriptions to English:\n\n{chunk_str}"
    response = model.generate_content(prompt)
    return response.text

def summarize_country_news(english_text):
    model = genai.GenerativeModel(MODEL_NAME)
    prompt = f"Summarize the following news into exactly 3 key sentences in English:\n\n{english_text}"
    response = model.generate_content(prompt)
    return response.text

def final_summary_6_sentences(all_45_sentences_text):
    model = genai.GenerativeModel(MODEL_NAME)
    prompt = f"Summarize the following global news points into exactly 6 key sentences in English, one per line:\n\n{all_45_sentences_text}"
    response = model.generate_content(prompt)
    sentences = [s.strip() for s in response.text.strip().split('\n') if s.strip()]
    # Ensure we get clean sentences
    clean_sentences = []
    for s in sentences:
        s = s.lstrip('0123456789.-* ')
        if s:
            clean_sentences.append(s)
    return clean_sentences[:6]

def translate_6_sentences_to_korean(sentences):
    model = genai.GenerativeModel(MODEL_NAME)
    text_to_translate = "\n".join(sentences)
    prompt = f"Translate the following sentences to Korean. Maintain the exact line separation, one per line:\n\n{text_to_translate}"
    response = model.generate_content(prompt)
    kr_sentences = [s.strip() for s in response.text.strip().split('\n') if s.strip()]
    clean_kr = []
    for s in kr_sentences:
        s = s.lstrip('0123456789.-* ')
        if s:
            clean_kr.append(s)
    return clean_kr[:6]

def analyze_sentiment(korean_sentences):
    model = genai.GenerativeModel(MODEL_NAME)
    text = "\n".join(korean_sentences)
    prompt = f"Analyze the overall sentiment of the following 6 news sentences. Respond with EXACTLY ONE word from these three options: '어두움', '보통', '밝음'. Do not include any other text.\n\nSentences:\n{text}"
    response = model.generate_content(prompt)
    res = response.text.strip().replace("'", "").replace('"', "")
    if res not in ['어두움', '보통', '밝음']:
        res = '보통'
    return res

def extract_stock_theme(korean_sentences):
    model = genai.GenerativeModel(MODEL_NAME)
    text = "\n".join(korean_sentences)
    prompt = f"Based on the following 6 global news sentences, what is the single most highly liquid stock market 'Theme' (테마) word in Korean? Respond with exactly one short phrase (e.g., '반도체', 'AI', '친환경 에너지'). Do not explain.\n\nSentences:\n{text}"
    response = model.generate_content(prompt)
    return response.text.strip()
