# retrain_pca.py

import joblib
import pandas as pd
from transformers import AutoTokenizer, AutoModel
import torch
import numpy as np
from sklearn.decomposition import PCA
import os
from main import preprocess_hebrew_text, mean_pooling

MODELS_DIR = 'models'
EXAMPLE_STATEMENTS = [
    "אני מרגישה עייפות נפשית",
    "אני לא מצליחה להתרכז בלימודים",
    "אני מרגיש לבד ולא מובן",
    "אני כועסת על כל דבר קטן",
    "אני לא יודע איך להמשיך",
    "אני עייפה כל הזמן ולא מצליחה לקום",
    "אני מרגיש חסר ערך",
    "אין לי חשק לעשות שום דבר",
    "הכל מרגיש לי מיותר",
    "אני חושבת שאני לא מספיק טובה"
]


# Load HeBERT
print("Loading HeBERT...")
tokenizer = AutoTokenizer.from_pretrained("avichr/heBERT")
model = AutoModel.from_pretrained("avichr/heBERT")

# Preprocess and encode
processed = [preprocess_hebrew_text(s) for s in EXAMPLE_STATEMENTS]
encoded = tokenizer(processed, padding=True, truncation=True, return_tensors='pt')

with torch.no_grad():
    model_output = model(**encoded)

embeddings = mean_pooling(model_output, encoded['attention_mask']).numpy()

# Train PCA on these embeddings
print("Training PCA...")
n_components = min(10, embeddings.shape[0])  # 10 or number of samples
pca = PCA(n_components=n_components, random_state=42)
pca.fit(embeddings)

# Save new reducer
os.makedirs(MODELS_DIR, exist_ok=True)
joblib.dump(pca, f"{MODELS_DIR}/reducer.joblib")
print("✅ New reducer.joblib saved with shape:", embeddings.shape)
