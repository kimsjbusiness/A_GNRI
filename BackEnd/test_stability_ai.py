import httpx
import os
from dotenv import load_dotenv

load_dotenv(dotenv_path="backend/.env")

async def test_stability_ai():
    api_key = os.getenv("SDXL_API_KEY")
    # Stability AI Text-to-Image URL
    api_url = "https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image"
    
    headers = {
        "Accept": "application/json",
        "Authorization": f"Bearer {api_key}"
    }
    
    payload = {
        "text_prompts": [{"text": "A beautiful sunset over the ocean"}],
        "cfg_scale": 7,
        "height": 1024,
        "width": 1024,
        "samples": 1,
        "steps": 30,
    }
    
    print(f"Testing Stability AI URL with key: {api_key[:10]}...")
    async with httpx.AsyncClient(timeout=30.0) as client:
        try:
            response = await client.post(api_url, headers=headers, json=payload)
            print(f"Status Code: {response.status_code}")
            if response.status_code == 200:
                print("Success! This is a Stability AI key.")
            else:
                print(f"Error: {response.text}")
        except Exception as e:
            print(f"Exception: {e}")

if __name__ == "__main__":
    import asyncio
    asyncio.run(test_stability_ai())
