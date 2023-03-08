import pandas as pd

df = pd.read_csv("./data/phishing_site_urls.csv")

from core import get_domain

df["domain"] = df["URL"].apply(get_domain)
df = df[df.Label == "bad"]
df.drop(columns=["URL", "Label"], inplace=True)
df.drop_duplicates(subset=["domain"], inplace=True)
df.to_csv("./data/phishing_domains.csv", index=False)
