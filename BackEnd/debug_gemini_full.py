import google.generativeai as genai
import os
import sys

# backend 디렉토리를 path에 추가
sys.path.append(os.path.join(os.getcwd(), "backend"))

from app.core.config import settings

def debug_gemini():
    api_key = settings.GEMINI_API_KEY
    print(f"--- Gemini Debug ---")
    print(f"API Key Length: {len(api_key) if api_key else 0}")
    print(f"API Key Prefix: {api_key[:7] if api_key else 'None'}...")
    
    if not api_key or "your_" in api_key:
        print("Error: 유효한 API 키가 설정되지 않았습니다.")
        return

    genai.configure(api_key=api_key)
    
    print("\n[접근 가능한 모델 목록]")
    try:
        models = genai.list_models()
        found_any = False
        for m in models:
            found_any = True
            print(f"- Name: {m.name}")
            print(f"  Methods: {m.supported_generation_methods}")
        
        if not found_any:
            print("결과: 접근 가능한 모델이 하나도 없습니다. API 키 권한을 확인해주세요.")
            
    except Exception as e:
        print(f"에러 발생: {e}")

if __name__ == "__main__":
    debug_gemini()
