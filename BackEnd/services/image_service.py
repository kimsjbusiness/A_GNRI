import os
import requests
from dotenv import load_dotenv

load_dotenv()

SDXL_API_URL = os.getenv("SDXL_API_URL", "https://api-inference.huggingface.co/models/stabilityai/sdxl-turbo")
SDXL_API_KEY = os.getenv("SDXL_API_KEY")

def generate_image(prompt):
    """
    Generate an image using SDXL Turbo and return image bytes.
    """
    if not SDXL_API_KEY:
        print("Warning: SDXL_API_KEY not set")
        return None
        
    headers = {"Authorization": f"Bearer {SDXL_API_KEY}"}
    payload = {"inputs": prompt}
    
    response = requests.post(SDXL_API_URL, headers=headers, json=payload)
    if response.status_code == 200:
        return response.content
    else:
        print(f"Failed to generate image: {response.status_code} - {response.text}")
        return None
