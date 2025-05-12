from flask import Flask, request, jsonify
from sentence_transformers import SentenceTransformer
import joblib
import firebase_admin
from firebase_admin import credentials, firestore

# Load model and scaler
model = joblib.load("regression_model.pkl")
scaler = joblib.load("target_scaler.pkl")
labse = SentenceTransformer("sentence-transformers/LaBSE")

# Initialize Firebase
cred = credentials.Certificate("serviceAccountKey.json")  # path to your service account key
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


# # api.py

# from flask import Flask, request, jsonify
# from sentence_transformers import SentenceTransformer
# import joblib

# # Load saved model and LaBSE
# model = joblib.load("regression_model.pkl")
# labse = SentenceTransformer("sentence-transformers/LaBSE")

# app = Flask(__name__)

# @app.route("/predict", methods=["POST"])
# def predict():
#     data = request.get_json()
#     sentence = data.get("statement")

#     if not sentence:
#         return jsonify({"error": "No input statement provided."}), 400

#     embedding = labse.encode([sentence])
#     prediction = model.predict(embedding)[0]

#     return jsonify({"prediction": round(float(prediction), 2)})

# if __name__ == "__main__":
#     import threading

#     def run_flask():
#         app.run(debug=True, use_reloader=False, port=5000)

#     def test_model():
#         while True:
#             user_input = input("\nEnter a statement to predict its score (or type 'exit' to quit): ")
#             if user_input.lower() == 'exit':
#                 break
#             user_embedding = labse.encode([user_input])
#             prediction = model.predict(user_embedding)[0]
#             print(f"Predicted score: {round(float(prediction), 2)}")

#     # Run Flask server and CLI tester in parallel
#     threading.Thread(target=run_flask).start()
#     test_model()
