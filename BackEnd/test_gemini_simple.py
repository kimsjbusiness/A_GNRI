import google.generativeai as genai
import os
from dotenv import load_dotenv

# Load .env directly
load_dotenv(dotenv_path="backend/.env")

def test_gen():
    api_key = os.getenv("GEMINI_API_KEY")
    print(f"Testing with API Key: {api_key[:7]}...")
    
    genai.configure(api_key=api_key)
    model = genai.GenerativeModel('gemini-1.5-flash')
    
    try:
        response = model.generate_content("Hello, are you working?")
        print("Response:", response.text)
        print("Success!")
    except Exception as e:
        print("Error during generation:", e)

if __name__ == "__main__":
    test_gen()
