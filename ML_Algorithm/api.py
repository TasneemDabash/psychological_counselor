from flask import Flask, request, jsonify
from sentence_transformers import SentenceTransformer
import joblib
import firebase_admin
from firebase_admin import credentials, firestore

# Load model and scaler
model = joblib.load("Models/regression_model.pkl")
scaler = joblib.load("Models/target_scaler.pkl")
labse = SentenceTransformer("sentence-transformers/LaBSE")

# Initialize Firebase
cred = credentials.Certificate("serviceAccountKey.json") 
firebase_admin.initialize_app(cred)
db = firestore.client()

app = Flask(__name__)

@app.route("/predict", methods=["POST"])
def predict():
    data = request.get_json()
    statement = data.get("statement")
    user_id = data.get("userId")  # from Flutter

    if not statement or not user_id:
        return jsonify({"error": "Missing statement or userId"}), 400

    # Predict score
    embedding = labse.encode([statement])
    pred_scaled = model.predict(embedding)
    prediction = float(scaler.inverse_transform([[pred_scaled[0]]])[0][0])

    # Save to Firestore
    db.collection("user_predictions").add({
        "userId": user_id,
        "statement": statement,
        "predictedScore": prediction,
        "timestamp": firestore.SERVER_TIMESTAMP
    })

    return jsonify({"prediction": round(prediction, 2)})


if __name__ == "__main__":
    app.run(debug=True, port=5000)