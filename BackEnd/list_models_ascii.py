import google.generativeai as genai
import os
from dotenv import load_dotenv

load_dotenv(dotenv_path="backend/.env")

def list_models():
    api_key = os.getenv("GEMINI_API_KEY")
    genai.configure(api_key=api_key)
    
    try:
        models = genai.list_models()
        print("Available Models:")
        for m in models:
            # Print only ASCII to avoid encoding issues
            name = m.name.encode('ascii', 'ignore').decode('ascii')
            print(f"- {name}")
    except Exception as e:
        print("Error:", e)

if __name__ == "__main__":
    list_models()
