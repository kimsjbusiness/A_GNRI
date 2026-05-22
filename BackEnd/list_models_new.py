import os
from google import genai
from dotenv import load_dotenv

load_dotenv(dotenv_path="backend/.env")

def list_available_models():
    api_key = os.getenv("GEMINI_API_KEY")
    client = genai.Client(api_key=api_key)
    
    print("Listing models...")
    try:
        # Client.models.list() returns a list of model objects
        for model in client.models.list():
            # Let's see what attributes are available
            # Standard ones are name, display_name, description
            print(f"- Name: {model.name}")
            print(f"  Display Name: {model.display_name}")
    except Exception as e:
        print(f"Error listing models: {e}")

if __name__ == "__main__":
    list_available_models()
