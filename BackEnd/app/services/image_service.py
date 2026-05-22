import httpx
from typing import List
from app.core.config import settings

class ImageService:
    def __init__(self):
        self.api_url = settings.SDXL_API_URL
        self.headers = {"Authorization": f"Bearer {settings.SDXL_API_KEY}"}

    async def generate_image(self, prompt: str) -> bytes:
        """Generate a single image from a prompt using SDXL Turbo."""
        payload = {
            "inputs": prompt,
            "parameters": {
                "num_inference_steps": 1, # SDXL Turbo is optimized for 1-4 steps
                "guidance_scale": 0.0,
            }
        }
        
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(self.api_url, headers=self.headers, json=payload)
            if response.status_code != 200:
                # Fallback or error logging
                raise Exception(f"Image generation failed: {response.text}")
            
            return response.content

    async def generate_images_for_sentences(self, sentences: List[str]) -> List[bytes]:
        """Generate images for multiple sentences."""
        images = []
        for sentence in sentences:
            # We might want to translate the sentence back to English or optimize prompt
            # But the plan says "images that explain each of the 3 sentences"
            # Since SDXL works best with English, I'll use a simple wrapper for prompt enhancement if needed.
            image_data = await self.generate_image(sentence)
            images.append(image_data)
        return images

image_service = ImageService()
