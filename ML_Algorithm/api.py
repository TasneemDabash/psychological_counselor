# # -*- coding: utf-8 -*-
# from flask import Flask, request, jsonify
# import joblib
# import numpy as np
# import os
# import logging
# from transformers import AutoTokenizer, AutoModel
# from main import (
#     generate_hebert_embedding,
#     determine_best_branch
# )  

# # Configure logging
# logging.basicConfig(level=logging.INFO)
# logger = logging.getLogger(__name__)

# app = Flask(__name__)

# # Load components only once (to save time)
# MODELS_DIR = 'models'
# try:
#     logger.info("Loading models...")
#     reducer = joblib.load("{}/reducer.joblib".format(MODELS_DIR))
#     logger.info("Loaded reducer")

#     path = "{}/branch_centroids.joblib".format(MODELS_DIR)
#     logger.info("Loading from: %s", path)
#     branch_centroids = joblib.load(path)
#     logger.info("Loaded branch centroids")

#     branch_boundaries = joblib.load(f"{MODELS_DIR}/branch_boundaries.joblib")
#     logger.info("Loaded branch boundaries")

#     # Load HeBERT
#     tokenizer = AutoTokenizer.from_pretrained("avichr/heBERT")
#     embedding_model = AutoModel.from_pretrained("avichr/heBERT")
#     logger.info("Loaded HeBERT model")

#     # Load best models and scalers
#     branch_models = {}
    
#     # First, find all available model files
#     model_files = {}
#     for filename in os.listdir(MODELS_DIR):
#         try:
#             if "_model.joblib" in filename:
#                 # Extract branch ID from filename
#                 parts = filename.split('_')
#                 if len(parts) >= 2 and parts[0] == 'branch':
#                     branch_id = int(parts[1])
#                     model_files[branch_id] = os.path.join(MODELS_DIR, filename)
#         except (ValueError, IndexError) as e:
#             logger.warning("Skipping file %s: %s", filename, str(e))
#             continue
    
#     logger.info("Found model files: %s", model_files)
    
#     # Then load models
#     for branch_id in range(3):
#         if branch_id in model_files:
#             try:
#                 branch_models[branch_id] = joblib.load(model_files[branch_id])
#                 logger.info("Loaded model for branch %d", branch_id)
#             except Exception as e:
#                 logger.error("Error loading branch %d: %s", branch_id, str(e))
#                 raise RuntimeError(f"Failed to load branch {branch_id}: {str(e)}")
#         else:
#             logger.error("Missing model file for branch %d", branch_id)
#             logger.error("Model file: %s", model_files.get(branch_id))
#             raise RuntimeError(f"Missing model file for branch {branch_id}")

#     logger.info("Successfully loaded all models")
#     logger.info("Available branches: %s", list(branch_models.keys()))

# except Exception as e:
#     logger.error("Error loading models: %s", str(e))
#     raise RuntimeError(f"Failed to load models: {str(e)}")

# @app.route('/', methods=['GET'])
# def home():
#     return jsonify({
#         'status': 'ok',
#         'message': 'Welcome to the Psychological Counselor API',
#         'endpoints': {
#             '/predict': 'POST - Send a statement for analysis',
#             '/health': 'GET - Check API health status'
#         }
#     })

# @app.route('/health', methods=['GET'])
# def health_check():
#     models_status = {
#         'embedding_model': bool(embedding_model),
#         'reducer': bool(reducer),
#         'branch_boundaries': branch_boundaries is not None and len(branch_boundaries) > 0,
#         'branch_centroids': branch_centroids is not None and len(branch_centroids) > 0,
#         'branch_models': bool(branch_models)
#     }
#     return jsonify({
#         'status': 'ok',
#         'models_loaded': all(models_status.values()),
#         'models_status': models_status
#     })

# @app.route('/predict', methods=['POST'])
# def predict():
#     data = request.get_json()
#     statement = data.get('statement')

#     if not statement:
#         return jsonify({
#             'error': 'No input statement provided',
#             'status': 'error'
#         }), 400

#     try:
#         logger.info("Processing statement: %s", 
#                    statement[:50] + "..." if len(statement) > 50 else statement)
        
#         # Preprocess and embed
#         try:
#             embedding = generate_hebert_embedding(statement, tokenizer, embedding_model)
#             logger.info("Generated embedding with shape: %s", embedding.shape)
#         except Exception as e:
#             logger.error("Error generating embedding: %s", str(e))
#             return jsonify({
#                 'error': f'Failed to generate embedding: {str(e)}',
#                 'status': 'error'
#             }), 500

#         try:
#             reduced_embedding = reducer.transform(embedding)
#             logger.info("Reduced embedding with shape: %s", reduced_embedding.shape)
#         except Exception as e:
#             logger.error("Error reducing embedding: %s", str(e))
#             return jsonify({
#                 'error': f'Failed to reduce embedding: {str(e)}',
#                 'status': 'error'
#             }), 500

#         # Add text features
#         length = len(statement)
#         word_count = len(statement.split())
#         combined = np.hstack([reduced_embedding, [[length, word_count]]])
#         logger.info("Combined features shape: %s", combined.shape)

#         # Select best branch
#         try:
#             best_branch = determine_best_branch(combined[0], branch_centroids)
#             logger.info("Selected branch: %d", best_branch)
#         except Exception as e:
#             logger.error("Error determining best branch: %s", str(e))
#             return jsonify({
#                 'error': f'Failed to determine best branch: {str(e)}',
#                 'status': 'error'
#             }), 500

#         # Predict
#         try:
#             logger.info("Making prediction for branch %d", best_branch)
#             logger.info("Available branch models: %s", list(branch_models.keys()))
            
#             if best_branch not in branch_models:
#                 raise KeyError(f"Branch {best_branch} not found in branch_models")
                
#             logger.info("Input shape: %s", combined.shape)
#             logger.info("Model type: %s", type(branch_models[best_branch]))
#             prediction = branch_models[best_branch].predict(combined)
#             logger.info("Raw prediction shape: %s", prediction.shape)
#             prediction = prediction[0]
#             logger.info("Raw prediction value: %f", prediction)
#         except KeyError as e:
#             logger.error("KeyError in prediction: %s", str(e))
#             logger.error("Available branches: %s", list(branch_models.keys()))
#             return jsonify({
#                 'error': f'Failed to make prediction: {str(e)}',
#                 'error_type': 'KeyError',
#                 'available_branches': list(branch_models.keys()),
#                 'status': 'error'
#             }), 500
#         except Exception as e:
#             logger.error("Error making prediction: %s", str(e))
#             logger.error("Error type: %s", type(e).__name__)
#             import traceback
#             logger.error("Traceback: %s", traceback.format_exc())
#             return jsonify({
#                 'error': f'Failed to make prediction: {str(e)}',
#                 'error_type': type(e).__name__,
#                 'status': 'error'
#             }), 500

#         # Clamp prediction
#         try:
#             low, high = branch_boundaries[best_branch], branch_boundaries[best_branch + 1]
#             prediction = float(np.clip(prediction, low, high))
#             logger.info("Final prediction: %.2f (clamped between %.2f and %.2f)", 
#                        prediction, low, high)
#         except Exception as e:
#             logger.error("Error clamping prediction: %s", str(e))
#             return jsonify({
#                 'error': f'Failed to clamp prediction: {str(e)}',
#                 'status': 'error'
#             }), 500

#         return jsonify({
#             'prediction': round(prediction, 2),
#             'branch': int(best_branch),
#             'status': 'success'
#         })

#     except Exception as e:
#         logger.error("Unexpected error in prediction: %s", str(e))
#         return jsonify({
#             'error': str(e),
#             'status': 'error',
#             'message': 'Failed to process prediction'
#         }), 500

# if __name__ == '__main__':
#     app.run(debug=True, port=5000)



# # from flask import Flask, request, jsonify
# # import os
# # import joblib
# # import numpy as np
# # import torch
# # from transformers import AutoTokenizer, AutoModel
# # import re
# # from sentence_transformers import SentenceTransformer

# # app = Flask(__name__)

# # # Paths to model files
# # MODELS_DIR = 'models'
# # MODEL_FILES = {
# #     0: None,  # Will be populated at startup
# #     1: None,
# #     2: None
# # }
# # SCALER_FILES = {
# #     0: None,  # Will be populated at startup
# #     1: None,
# #     2: None
# # }
# # REDUCER_PATH = os.path.join(MODELS_DIR, 'reducer.joblib')
# # BRANCH_BOUNDARIES_PATH = os.path.join(MODELS_DIR, 'branch_boundaries.joblib')
# # BRANCH_CENTROIDS_PATH = os.path.join(MODELS_DIR, 'branch_centroids.joblib')
# # EMBEDDING_MODEL_INFO_PATH = os.path.join(MODELS_DIR, 'embedding_model_info.joblib')
# # EMBEDDING_MODEL_PATH = os.path.join(MODELS_DIR, 'embedding_model.joblib')

# # # Global variables to store loaded models
# # embedding_model = None
# # tokenizer = None
# # reducer = None
# # branch_boundaries = None
# # branch_centroids = None
# # branch_models = {}
# # branch_scalers = {}

# # def preprocess_hebrew_text(text):
# #     """Hebrew-specific text preprocessing"""
# #     # Remove nikud (vowel points) if present
# #     text = re.sub(r'[\u0591-\u05C7]', '', text)
# #     # Normalize final forms of letters
# #     text = text.replace('ך', 'כ').replace('ם', 'מ').replace('ן', 'נ').replace('ף', 'פ').replace('ץ', 'צ')
# #     # Remove extra spaces
# #     text = re.sub(r'\s+', ' ', text).strip()
# #     return text

# # def mean_pooling(model_output, attention_mask):
# #     """Mean pooling function to convert token embeddings to sentence embeddings"""
# #     # First element of model_output contains all token embeddings
# #     token_embeddings = model_output[0]
# #     # Mask away padding tokens
# #     input_mask_expanded = attention_mask.unsqueeze(-1).expand(token_embeddings.size()).float()
# #     return torch.sum(token_embeddings * input_mask_expanded, 1) / torch.clamp(input_mask_expanded.sum(1), min=1e-9)

# # def generate_hebert_embedding(statement, tokenizer, model):
# #     """Generate embeddings for a new statement using HeBERT"""
# #     # Preprocess the statement
# #     processed_statement = preprocess_hebrew_text(statement)
    
# #     # Tokenize
# #     encoded_input = tokenizer([processed_statement], padding=True, truncation=True, max_length=128, return_tensors='pt')
    
# #     # Generate embeddings
# #     with torch.no_grad():
# #         model_output = model(**encoded_input)
    
# #     # Mean pooling
# #     sentence_embedding = mean_pooling(model_output, encoded_input['attention_mask'])
    
# #     return sentence_embedding.numpy()

# # def determine_best_branch(features, branch_centroids):
# #     """Determine the most appropriate branch for a new statement based on feature similarity"""
# #     # Method 1: Find closest centroid
# #     distances = {}
# #     for branch_id, centroid in branch_centroids.items():
# #         if centroid is not None:
# #             # Calculate Euclidean distance to centroid
# #             distance = np.linalg.norm(features - centroid)
# #             distances[branch_id] = distance
    
# #     # If we have valid distances, return the branch with the minimum distance
# #     if distances:
# #         return min(distances, key=distances.get)
    
# #     # Fallback to default branch (middle branch)
# #     return 1

# # def load_models():
# #     """Load all required models at startup"""
# #     global embedding_model, tokenizer, reducer, branch_boundaries, branch_centroids, branch_models, branch_scalers
    
# #     print("Loading models...")
    
# #     # Find model files for each branch
# #     for branch_id in range(3):  # Assuming 3 branches
# #         model_files = [f for f in os.listdir(MODELS_DIR) if f.startswith(f"branch_{branch_id}_") and f.endswith("_model.joblib")]
# #         scaler_files = [f for f in os.listdir(MODELS_DIR) if f.startswith(f"branch_{branch_id}_") and f.endswith("_scaler.joblib")]
        
# #         if model_files and scaler_files:
# #             MODEL_FILES[branch_id] = os.path.join(MODELS_DIR, model_files[0])
# #             SCALER_FILES[branch_id] = os.path.join(MODELS_DIR, scaler_files[0])
    
# #     # Load embedding model
# #     try:
# #         if os.path.exists(EMBEDDING_MODEL_INFO_PATH):
# #             # Load HeBERT model
# #             model_info = joblib.load(EMBEDDING_MODEL_INFO_PATH)
# #             model_name = model_info.get('model_name', 'avichr/heBERT')
            
# #             try:
# #                 tokenizer = AutoTokenizer.from_pretrained(model_name)
# #                 embedding_model = AutoModel.from_pretrained(model_name)
# #                 print(f"Loaded HeBERT model: {model_name}")
# #             except Exception as e:
# #                 print(f"Error loading HeBERT model: {str(e)}")
# #                 print("Falling back to default model...")
# #                 embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
# #                 tokenizer = None
# #                 print("Using all-MiniLM-L6-v2 model as fallback")
# #         elif os.path.exists(EMBEDDING_MODEL_PATH):
# #             # Load SentenceTransformer model
# #             embedding_model = joblib.load(EMBEDDING_MODEL_PATH)
# #             tokenizer = None
# #             print("Loaded SentenceTransformer embedding model")
# #         else:
# #             print("Embedding model not found, creating new one...")
# #             try:
# #                 tokenizer = AutoTokenizer.from_pretrained("avichr/heBERT")
# #                 embedding_model = AutoModel.from_pretrained("avichr/heBERT")
# #                 print("Using HeBERT model")
# #             except Exception as e:
# #                 print(f"Error loading HeBERT: {str(e)}")
# #                 embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
# #                 tokenizer = None
# #                 print("Using all-MiniLM-L6-v2 model as fallback")
# #     except Exception as e:
# #         print(f"Error loading embedding model: {str(e)}")
# #         return False
    
# #     # Load reducer
# #     try:
# #         if os.path.exists(REDUCER_PATH):
# #             reducer = joblib.load(REDUCER_PATH)
# #             print("Loaded reducer")
# #         else:
# #             print("Reducer not found")
# #             return False
# #     except Exception as e:
# #         print(f"Error loading reducer: {str(e)}")
# #         return False
    
# #     # Load branch boundaries
# #     try:
# #         if os.path.exists(BRANCH_BOUNDARIES_PATH):
# #             branch_boundaries = joblib.load(BRANCH_BOUNDARIES_PATH)
# #             print("Loaded branch boundaries")
# #         else:
# #             print("Branch boundaries not found")
# #             return False
# #     except Exception as e:
# #         print(f"Error loading branch boundaries: {str(e)}")
# #         return False
    
# #     # Load branch centroids
# #     try:
# #         if os.path.exists(BRANCH_CENTROIDS_PATH):
# #             branch_centroids = joblib.load(BRANCH_CENTROIDS_PATH)
# #             print("Loaded branch centroids")
# #         else:
# #             print("Branch centroids not found")
# #             return False
# #     except Exception as e:
# #         print(f"Error loading branch centroids: {str(e)}")
# #         return False
    
# #     # Load branch models and scalers
# #     for branch_id in range(3):
# #         if MODEL_FILES[branch_id] and SCALER_FILES[branch_id]:
# #             try:
# #                 branch_models[branch_id] = joblib.load(MODEL_FILES[branch_id])
# #                 branch_scalers[branch_id] = joblib.load(SCALER_FILES[branch_id])
# #                 print(f"Loaded model for Branch {branch_id}: {MODEL_FILES[branch_id]}")
# #             except Exception as e:
# #                 print(f"Error loading model for Branch {branch_id}: {str(e)}")
# #                 return False
    
# #     if not branch_models:
# #         print("No branch models loaded")
# #         return False
    
# #     print("All models loaded successfully")
# #     return True

# # def predict_mean_cave(statement):
# #     """Predict mean cave value for a statement"""
# #     try:
# #         # Generate embedding
# #         if tokenizer is not None:
# #             # Using HeBERT
# #             embedding = generate_hebert_embedding(statement, tokenizer, embedding_model)
# #         else:
# #             # Fallback to SentenceTransformer
# #             embedding = embedding_model.encode([preprocess_hebrew_text(statement)])
        
# #         # Apply dimensionality reduction
# #         reduced_embedding = reducer.transform(embedding)
        
# #         # Add text-based features
# #         text_length = len(statement)
# #         word_count = len(statement.split())
# #         additional_features = np.array([[text_length, word_count]])
        
# #         # Combine features
# #         combined_features = np.hstack([reduced_embedding, additional_features])
        
# #         # Get predictions from all branch models
# #         branch_predictions = {}
        
# #         for branch_id, model in branch_models.items():
# #             # Scale features using the branch's scaler
# #             scaled_features = branch_scalers[branch_id].transform(combined_features)
            
# #             # Make prediction
# #             prediction = model.predict(scaled_features)[0]
# #             branch_predictions[branch_id] = prediction
        
# #         # Determine the best branch for this statement based on feature similarity
# #         best_branch_id = determine_best_branch(combined_features[0], branch_centroids)
        
# #         # Get the prediction from the best branch
# #         final_prediction = branch_predictions[best_branch_id]
        
# #         # Ensure the prediction is within the branch's range
# #         min_val = branch_boundaries[best_branch_id]
# #         max_val = branch_boundaries[best_branch_id+1]
# #         final_prediction = max(min_val, min(final_prediction, max_val))
        
# #         # Return all predictions and the final one
# #         return {
# #             'success': True,
# #             'branch_predictions': {str(k): float(v) for k, v in branch_predictions.items()},
# #             'best_branch': int(best_branch_id),
# #             'final_prediction': float(final_prediction),
# #             'branch_ranges': {str(i): [float(branch_boundaries[i]), float(branch_boundaries[i+1])] for i in range(len(branch_boundaries)-1)}
# #         }
# #     except Exception as e:
# #         return {
# #             'success': False,
# #             'error': str(e)
# #         }

# # @app.route('/health', methods=['GET'])
# # def health_check():
# #     """Health check endpoint"""
# #     return jsonify({
# #         'status': 'ok',
# #         'models_loaded': bool(embedding_model and reducer and branch_boundaries and branch_centroids and branch_models)
# #     })

# # @app.route('/predict', methods=['POST'])
# # def predict():
# #     """Prediction endpoint"""
# #     data = request.get_json()
    
# #     if not data or 'statement' not in data:
# #         return jsonify({
# #             'success': False,
# #             'error': 'Missing statement in request'
# #         }), 400
    
# #     statement = data['statement']
# #     result = predict_mean_cave(statement)
    
# #     if result['success']:
# #         return jsonify(result)
# #     else:
# #         return jsonify(result), 500

# # @app.route('/batch_predict', methods=['POST'])
# # def batch_predict():
# #     """Batch prediction endpoint"""
# #     data = request.get_json()
    
# #     if not data or 'statements' not in data:
# #         return jsonify({
# #             'success': False,
# #             'error': 'Missing statements in request'
# #         }), 400
    
# #     statements = data['statements']
# #     results = []
    
# #     for statement in statements:
# #         result = predict_mean_cave(statement)
# #         if result['success']:
# #             results.append({
# #                 'statement': statement,
# #                 'prediction': result['final_prediction'],
# #                 'branch': result['best_branch']
# #             })
# #         else:
# #             results.append({
# #                 'statement': statement,
# #                 'error': result['error']
# #             })
    
# #     return jsonify({
# #         'success': True,
# #         'results': results
# #     })

# # if __name__ == '__main__':
# #     # Load models at startup
# #     if load_models():
# #         # Run the Flask app
# #         app.run(host='0.0.0.0', port=5000, debug=False)
# #     else:
# #         print("Failed to load models. Please ensure all required model files are available.")

# # Firebase Functions for therapyrobot-a8d2f Project
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from flask import Flask, request, jsonify
from attribution_bot import get_gpt_response

import firebase_admin
from firebase_admin import credentials, firestore

if not firebase_admin._apps:
    cred = credentials.Certificate("/Users/tasneemdabash/Desktop/final/psychological_counselor/ML_Algorithm/therapyrobot-a8d2f-firebase-adminsdk-4nmam-0014eeaa1f.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

app = Flask(__name__)

@app.route("/attribution", methods=["POST"])
def attribution():
    data = request.get_json()
    event = data.get("event")
    emotion = data.get("emotion")
    reason = data.get("reason")
    language = data.get("language", "he")

    if not event or not emotion or not reason:
        return jsonify({"error": "Missing required fields: event, emotion, or reason"}), 400

    print(f"📅 Received attribution request: {data}")
    prompt = f"האירוע הוא: '{event}', הסיבה המרכזית: '{reason}', והרגשות שעולים הם: '{emotion}'."

    reflection = get_gpt_response(prompt, language=language)
    return jsonify({"response": reflection})

# ============ 🔮 MeanCAVE Prediction Endpoint ============
from main import predict_mean_cave, AutoTokenizer, AutoModel
import joblib

# Load once
tokenizer = AutoTokenizer.from_pretrained("avichr/heBERT")
embedding_model = AutoModel.from_pretrained("avichr/heBERT")
reducer = joblib.load("models/reducer.joblib")
branch_centroids = joblib.load("models/branch_centroids.joblib")
branch_boundaries = joblib.load("models/branch_boundaries.joblib")

@app.route("/predict", methods=["POST"])
def predict():
    data = request.get_json()
    user_id = data.get("userId")
    statement = data.get("statement")

    if not user_id or not statement:
        return jsonify({"error": "Missing userId or statement"}), 400

    try:
        print(f"🔍 Predicting for user {user_id}: {statement}")
        result = predict_mean_cave(statement, tokenizer, embedding_model, reducer, branch_centroids, branch_boundaries)
        return jsonify(result)
    except FileNotFoundError as fnf_error:
        return jsonify({"error": str(fnf_error)}), 500
    except Exception as e:
        return jsonify({"error": f"Unexpected error: {str(e)}"}), 500

# import os
# from flask import Flask, request, jsonify
# from attribution_bot import get_gpt_response

# app = Flask(__name__)

# @app.route("/attribution", methods=["POST"])
# def attribution():
#     data = request.get_json()

#     event = data.get("event")
#     emotion = data.get("emotion")
#     reason = data.get("reason")

#     if not event or not emotion or not reason:
#         return jsonify({"error": "Missing required fields: event, emotion, or reason"}), 400

#     print(f"📥 Received attribution request: {data}")

#     prompt = (
#         f"האירוע הוא: '{event}', "
#         f"הסיבה המרכזית: '{reason}', "
#         f"והרגשות שעולים הם: '{emotion}'."
#     )

#     reflection = get_gpt_response(prompt)
#     return jsonify({"response": reflection})

# if __name__ == "__main__":
#     app.run(host='0.0.0.0', port=5000, debug=True)
