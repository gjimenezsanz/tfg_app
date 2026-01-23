# Fichero Python de prueba para modelo de OpenRouter
# Requiere la librería requests: pip install requests
# Requiere la librería json: pip install json
# Requiere la librería openrouter: pip install openrouter
# Arranque con: python3 lib/services/prueba_openrouter.py

import requests
import json

API_KEY = "REDACTED_OPENROUTER_KEY"  # API Key OpenRouter
message = "hi"  # Mensaje del usuario

headers = {
        "Authorization": f"Bearer {API_KEY}",
}

body = {
        "model": "meta-llama/llama-3.3-8b-instruct:free", # Modelo de OpenRouter
        "messages": [{"role": "user", "content": message}] # //Prompt 
}

response = requests.post(
        "https://openrouter.ai/api/v1/chat/completions", # Endpoint de OpenRouter: url para peticiones POST
        headers=headers,
        json=body 
)

# Verifica si la respuesta es correcta
if response.status_code == 200:
    data = response.json()
    content = data.get("choices", [{}])[0].get("message", {}).get("content", "")
    print({"response": content})
else:
    print({"error": response.text})