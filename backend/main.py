import numpy as np
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from core import get_domain, is_safe_url, load_model, mongodb_connect, is_popular

app = FastAPI()

CORSMiddleware(
    app,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/api/predict")
def predict(url: str):
    url = url.lower()
    url = url.split("?", 1)[0]

    if not is_safe_url(url):
        return {"domain": url, "prediction": "bad", "isSafe": False}

    domain = get_domain(url)
    if is_popular(domain):
        return {"domain": domain, "prediction": "good", "isSafe": True}

    model = load_model()
    prediction = model.predict(np.array([url]))

    client = mongodb_connect()
    collection = client["admin"]["Phishing-Domains"]
    if collection.find_one({"domain": domain}):
        return {"domain": domain, "prediction": "bad", "isSafe": False}

    result = dict()
    result["domain"] = domain
    result["prediction"] = prediction[0]
    result["isSafe"] = prediction[0] == "good"

    if not result["isSafe"]:
        collection.insert_one({"domain": domain})

    return result


if __name__ == "__main__":
    uvicorn.run(app)
