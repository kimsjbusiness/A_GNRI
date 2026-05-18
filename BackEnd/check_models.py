import google.generativeai as genai
import os
from dotenv import load_dotenv

# 현재 디렉토리의 .env 로드
load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")

if not api_key or "your_gemini_api_key" in api_key:
    print(f"Error: 유효한 GEMINI_API_KEY를 찾을 수 없습니다. (현재 값: {api_key})")
else:
    genai.configure(api_key=api_key)
    print("사용 가능한 모델 목록:")
    try:
        for m in genai.list_models():
            if 'generateContent' in m.supported_generation_methods:
                print(f"- {m.name}")
    except Exception as e:
        print(f"모델 목록 조회 실패: {e}")
