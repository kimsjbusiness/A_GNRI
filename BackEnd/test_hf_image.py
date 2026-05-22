import httpx
import os
from dotenv import load_dotenv

load_dotenv(dotenv_path="backend/.env")

async def test_hf_image():
    api_url = os.getenv("SDXL_API_URL")
    api_key = os.getenv("SDXL_API_KEY")
    headers = {"Authorization": f"Bearer {api_key}"}
    
    payload = {"inputs": "A beautiful sunset over the ocean"}
    
    print(f"Testing URL: {api_url}")
    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.post(api_url, headers=headers, json=payload)
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            print("Success!")
        else:
            print(f"Error: {response.text}")

if __name__ == "__main__":
    import asyncio
    asyncio.run(test_hf_image())
