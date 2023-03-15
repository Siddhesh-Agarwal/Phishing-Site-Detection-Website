import pickle
import re
import pandas as pd
import pymongo


def mongodb_connect():
    """Connect to MongoDB Atlas"""
    client = pymongo.MongoClient("mongodb://localhost:27017/")
    return client


def get_domain(url: str) -> str:
    """Get domain from URL"""

    url = url.lower()
    website: str = url.lstrip("https://")
    website = website.lstrip("http://")
    website = website.lstrip("www.")
    website = website.split("/", 1)[0]
    return website


def load_model():
    """Load the model from pickle file"""

    with open("model.pkl", "rb") as f:
        model = pickle.load(f)
    return model


def is_safe_url(string: str) -> bool:
    """
    Check if the string is a valid URL (No query parameters).
    string is a lowercase string.
    It is not on localhost.
    It is not an IP address.
    """

    string = string.lower().split("?", 1)[0]
    if get_domain(string) == "localhost":
        return False
    if string.startswith("http://"):
        return False
    if re.match(r"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$", get_domain(string)):
        return False
    return re.match(r"^(?:https|ftps)://", string)

def is_popular(domain: str) -> bool:
    """
    Check if the domain is a popular.
    """
    df = pd.read_parquet("./data/popular-websites.parquet")
    return domain in df["website"].values
