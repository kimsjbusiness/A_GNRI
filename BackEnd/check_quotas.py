import os
from google import genai
from dotenv import load_dotenv

load_dotenv(dotenv_path="backend/.env")

def check_quotas():
    api_key = os.getenv("GEMINI_API_KEY")
    client = genai.Client(api_key=api_key)
    
    models = [
        'gemini-2.5-flash',
        'gemini-2.0-flash',
        'gemini-flash-latest',
        'gemini-pro-latest',
        'gemini-2.0-flash-lite'
    ]
    
    for m in models:
        print(f"\nChecking {m}...")
        try:
            resp = client.models.generate_content(model=m, contents="hi")
            print(f"  OK! Response: {resp.text.strip()}")
        except Exception as e:
            print(f"  Failed: {e}")

if __name__ == "__main__":
    check_quotas()
