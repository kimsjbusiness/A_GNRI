import os
from google import genai
from dotenv import load_dotenv

load_dotenv(dotenv_path="backend/.env")

def test_gemini_v2():
    api_key = os.getenv("GEMINI_API_KEY")
    client = genai.Client(api_key=api_key)
    
    # Try models that were in the list
    models_to_try = [
        'gemini-2.0-flash', 
        'gemini-flash-latest', 
        'gemini-pro-latest'
    ]
    
    for model_id in models_to_try:
        print(f"\nTrying model: {model_id}")
        try:
            response = client.models.generate_content(
                model=model_id,
                contents="Hello, this is a test. Please reply with 'Success'."
            )
            print(f"Success with {model_id}!")
            print("Response:", response.text)
            return
        except Exception as e:
            print(f"Failed with {model_id}: {e}")

if __name__ == "__main__":
    test_gemini_v2()
