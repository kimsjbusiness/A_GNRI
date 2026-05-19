import os
from google import genai
from dotenv import load_dotenv

load_dotenv(dotenv_path="backend/.env")

def test_gemini_new_key():
    api_key = os.getenv("GEMINI_API_KEY")
    print(f"Testing with Key: {api_key[:10]}...")
    client = genai.Client(api_key=api_key)
    
    models = ['gemini-2.0-flash-lite', 'gemini-1.5-flash', 'gemini-pro']
    
    for model_id in models:
        print(f"\nTrying model: {model_id}")
        try:
            response = client.models.generate_content(
                model=model_id,
                contents="Hello, this is a test."
            )
            print(f"Success with {model_id}!")
            print("Response:", response.text)
            return
        except Exception as e:
            print(f"Failed with {model_id}: {e}")

if __name__ == "__main__":
    test_gemini_new_key()
