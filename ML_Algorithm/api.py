
from flask import Flask, request, jsonify
from model.predictor import predict_mean_cave  # <-- use your own function
import firebase_admin
from firebase_admin import credentials, firestore

app = Flask(__name__)

# Initialize Firebase
cred = credentials.Certificate("firebase_key.json")  # path to your Firebase service account
firebase_admin.initialize_app(cred)
db = firestore.client()

@app.route("/predict", methods=["POST"])
def predict_and_store():
    data = request.get_json()
    statement = data.get("statement")
    user_id = data.get("userId")

    if not statement or not user_id:
        return jsonify({"error": "Missing required fields"}), 400

    try:
        mean_cave = predict_mean_cave(statement)  # ⬅️ your internal logic
        doc_ref = db.collection("predictions").add({
            "userId": user_id,
            "statement": statement,
            "meanCAVE": mean_cave,
        })
        return jsonify({"meanCAVE": mean_cave, "docId": doc_ref[1].id})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(port=5000, debug=True)



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
