import httpx
import os
from dotenv import load_dotenv

load_dotenv(dotenv_path="backend/.env")

async def find_working_hf_model():
    api_key = os.getenv("SDXL_API_KEY")
    headers = {"Authorization": f"Bearer {api_key}"}
    
    # List of common models to try
    models = [
        "stabilityai/sdxl-turbo",
        "stabilityai/stable-diffusion-xl-base-1.0",
        "runwayml/stable-diffusion-v1-5",
        "stabilityai/stable-diffusion-2-1"
    ]
    
    async with httpx.AsyncClient(timeout=20.0) as client:
        for model in models:
            url = f"https://api-inference.huggingface.co/models/{model}"
            print(f"Trying {model}...")
            try:
                # We use a very simple query to check availability
                response = await client.post(url, headers=headers, json={"inputs": "test"})
                print(f"Status: {response.status_code}")
                if response.status_code in [200, 503]: # 503 means model is loading, which is fine
                    print(f"Model {model} is available!")
                    return model
            except Exception as e:
                print(f"Error: {e}")
    return None

if __name__ == "__main__":
    import asyncio
    asyncio.run(find_working_hf_model())
