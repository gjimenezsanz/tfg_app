from flask import Flask, request, jsonify
import requests
import json

API_KEY = "REDACTED_OPENROUTER_KEY"  # API Key OpenRouter
REFERER = "<url>"
TITLE = "<title>"
app = Flask(__name__)
@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    message = data.get("message", "")  # Mensaje del usuario

    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Referer": REFERER, 
        "X-Title": TITLE,
        "Content-Type": "application/json"
    }

    body = {
        "model": "allenai/molmo-7b-d:free", # Modelo de OpenRouter
        "messages": [{"role": "user", "content": message}] # //Prompt del usuario ---> IA a modificar
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
        return jsonify({"response": content})
    else:
        return jsonify({"error": response.text}), response.status_code

# app = Flask(__name__)
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5050)  # ✅ Acepta conexiones externas
