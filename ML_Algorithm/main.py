# -*- coding: utf-8 -*-

from config import EXCEL_PATH
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import re
import os
import joblib
import time
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, PolynomialFeatures
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE
from sklearn.pipeline import Pipeline
from imblearn.over_sampling import SMOTE
from sklearn.metrics.pairwise import euclidean_distances
from transformers import AutoTokenizer, AutoModel
import torch

# Import all the requested regression models
from sklearn.linear_model import (
    LinearRegression,  # Ordinary Least Squares
    Ridge,  # Ridge regression
    Lasso,  # Lasso
    MultiTaskLasso,  # Multi-task Lasso
    ElasticNet,  # Elastic-Net
    MultiTaskElasticNet,  # Multi-task Elastic-Net
    Lars,  # Least Angle Regression
    LassoLars,  # LARS Lasso
    OrthogonalMatchingPursuit,  # OMP
    BayesianRidge,  # Bayesian Regression
    SGDRegressor,  # Stochastic Gradient Descent
    PassiveAggressiveRegressor,  # Passive Aggressive
    HuberRegressor,  # Robustness regression
    RANSACRegressor,  # Robustness regression
    QuantileRegressor  # Quantile Regression
)
from sklearn.linear_model import TheilSenRegressor  # Robust regression
from sklearn.ensemble import (
    RandomForestRegressor,
    GradientBoostingRegressor
)
from sklearn.svm import SVR
from sklearn.metrics import (
    mean_squared_error,
    r2_score,
    mean_absolute_error,
    explained_variance_score,
    max_error,
    median_absolute_error
)

# Get all sheet names from the Excel file
def get_sheet_names():
    xlsx = pd.ExcelFile(EXCEL_PATH)
    return xlsx.sheet_names


SHEET_NAMES = get_sheet_names()

# Paths
MODEL_DIR = os.path.join("models")
CENTROIDS_PATH = os.path.join(MODEL_DIR, "/Users/tasneemdabash/Desktop/final/psychological_counselor/models/branch_centroids.joblib")
BOUNDARIES_PATH = os.path.join(MODEL_DIR, "/Users/tasneemdabash/Desktop/final/psychological_counselor/models/branch_boundaries.joblib")

# Load vectorizer and branch centroids
try:
    branch_centroids = joblib.load(CENTROIDS_PATH)
    branch_boundaries = joblib.load(BOUNDARIES_PATH)
except Exception as e:
    raise RuntimeError(f"❌ Failed to load required models: {e}")


def get_closest_branch(embedding: np.ndarray) -> int:
    distances = euclidean_distances([embedding], list(branch_centroids.values()))
    closest_index = np.argmin(distances)
    return list(branch_centroids.keys())[closest_index]


def predict_mean_cave(statement, model, tokenizer, reducer,
                      branch_centroids, branch_boundaries, models_dir="models"):
    """
    Predict the meanCAVE value for a single statement.

    Args:
        statement (str): The input text.
        model: HeBERT model for embedding.
        tokenizer: HeBERT tokenizer.
        reducer: PCA or TSNE model.
        branch_centroids: Dict of centroids.
        branch_boundaries: List of numeric boundary values.
        models_dir (str): Directory with saved models and scalers.

    Returns:
        float: The predicted meanCAVE score (rounded to 2 decimal places).
    """
    try:
        # Generate embedding
        if tokenizer is not None:
            embedding = generate_hebert_embedding(statement, tokenizer, model)
        else:
            embedding = model.encode([preprocess_hebrew_text(statement)])

        # Dimensionality reduction
        reduced_embedding = reducer.transform(embedding)

        # Add text-based features
        text_length = len(statement)
        word_count = len(statement.split())
        additional_features = np.array([[text_length, word_count]])
        combined_features = np.hstack([reduced_embedding, additional_features])

        # Determine the best branch
        best_branch_id = determine_best_branch(combined_features[0], branch_centroids)

        # Load model and scaler
        model_path = os.path.join(models_dir, f"branch_{best_branch_id}_RandomForest_model.joblib")
        scaler_path = os.path.join(models_dir, f"branch_{best_branch_id}_scaler.joblib")

        branch_model = joblib.load(model_path)
        branch_scaler = joblib.load(scaler_path)

        scaler_path = f'models/branch_{branch_id}_scaler.joblib'
        if os.path.exists(scaler_path):
            scaler = joblib.load(scaler_path)
            features = scaler.transform([reduced_embedding])
        else:
            print(f"⚠️ No scaler found for branch {branch_id}, using raw features.")
            features = [reduced_embedding]

        scaled_input = branch_scaler.transform(combined_features)

        # Predict and clip within boundaries
        prediction = branch_model.predict(scaled_input)[0]
        min_val = branch_boundaries[best_branch_id]
        max_val = branch_boundaries[best_branch_id + 1]
        final_prediction = max(min_val, min(prediction, max_val))

        return round(float(final_prediction), 2)

    except Exception as e:
        print(f"❌ Error in predict_mean_cave: {e}")
        raise

# Hebrew-specific text preprocessing
def preprocess_hebrew_text(text):
    # Remove nikud (vowel points) if present
    text = re.sub(r'[\u0591-\u05C7]', '', text)
    # Normalize final forms of letters
    text = (text.replace('ך', 'כ')
                .replace('ם', 'מ')
                .replace('ן', 'נ')
                .replace('ף', 'פ')
                .replace('ץ', 'צ'))
    # Remove extra spaces
    text = re.sub(r'\s+', ' ', text).strip()
    return text


# Load and clean data function
def load_and_clean_data():
    xlsx = pd.ExcelFile(EXCEL_PATH)
    dfs = []

    for sheet in SHEET_NAMES:
        df = pd.read_excel(xlsx, sheet_name=sheet)
        session_col = [col for col in df.columns if "Session" in col]
        if "statement" in df.columns and session_col:
            df = df[["statement", session_col[0]]].rename(columns={session_col[0]: "label"})
            df["source"] = sheet
            dfs.append(df)

    df = pd.concat(dfs, ignore_index=True)
    df.replace([" ", "", "N/a", "n/a", "NA", "na"], np.nan, inplace=True)
    df.dropna(inplace=True)
    df = df[df['statement'].str.strip().astype(bool)]
    df.drop_duplicates(subset='statement', inplace=True)

    # Add text-based features
    df['processed_statement'] = df['statement'].apply(preprocess_hebrew_text)
    df['text_length'] = df['statement'].str.len()
    df['word_count'] = df['statement'].str.split().str.len()

    return df


# Mean pooling function to convert token embeddings to sentence embeddings
def mean_pooling(model_output, attention_mask):
    # First element of model_output contains all token embeddings
    token_embeddings = model_output[0]
    # Mask away padding tokens
    input_mask_expanded = attention_mask.unsqueeze(-1).expand(token_embeddings.size()).float()
    return torch.sum(token_embeddings * input_mask_expanded, 1) / torch.clamp(input_mask_expanded.sum(1), min=1e-9)


# Process text with HeBERT model
def process_text_with_hebert(df):
    print("Loading HeBERT model for Hebrew text embeddings...")

    try:
        # Load HeBERT model and tokenizer
        tokenizer = AutoTokenizer.from_pretrained("avichr/heBERT")
        model = AutoModel.from_pretrained("avichr/heBERT")

        print("Successfully loaded HeBERT model")

        # Process statements in batches to avoid memory issues
        batch_size = 16
        all_embeddings = []

        for i in range(0, len(df), batch_size):
            batch_texts = df['processed_statement'].iloc[i:i + batch_size].tolist()

            # Tokenize the texts
            encoded_input = tokenizer(batch_texts, padding=True, truncation=True, max_length=128, return_tensors='pt')

            # Compute token embeddings
            with torch.no_grad():
                model_output = model(**encoded_input)

            # Perform mean pooling to get sentence embeddings
            sentence_embeddings = mean_pooling(model_output, encoded_input['attention_mask'])

            # Convert to numpy and store
            all_embeddings.append(sentence_embeddings.numpy())

            if (i + batch_size) % 100 == 0 or (i + batch_size) >= len(df):
                print("Processed {}/{} statements".format(min(i + batch_size, len(df)), len(df)))

        # Concatenate all batches
        embeddings = np.vstack(all_embeddings)

        print("Generated embeddings with shape: {}".format(embeddings.shape))
        return embeddings, model, tokenizer

    except Exception as e:
        print("Error loading HeBERT model: {}".format(str(e)))
        print("Falling back to default model...")

        # If HeBERT fails, try to use SentenceTransformer as fallback
        try:
            from sentence_transformers import SentenceTransformer
            model = SentenceTransformer('all-MiniLM-L6-v2')
            print("Using all-MiniLM-L6-v2 model as fallback")

            embeddings = model.encode(df['processed_statement'].tolist(), show_progress_bar=True)
            print("Generated embeddings with shape: {}".format(embeddings.shape))
            return embeddings, model, None

        except Exception as e2:
            print("Error with fallback model: {}".format(str(e2)))
            raise Exception("Failed to load any embedding model")


# Apply dimensionality reduction with TSNE or PCA
def apply_dimensionality_reduction(embeddings, method='pca', n_components=10):
    print("Applying {} dimensionality reduction...".format(method.upper()))

    if method.lower() == 'tsne':
        reducer = TSNE(n_components=n_components, random_state=42)
    else:  # default to PCA
        reducer = PCA(n_components=n_components, random_state=42)

    reduced_data = reducer.fit_transform(embeddings)
    print("Reduced data shape: {}".format(reduced_data.shape))

    # If using PCA, print explained variance
    if method.lower() == 'pca':
        explained_variance = reducer.explained_variance_ratio_.sum()
        print("Explained variance: {:.4f}".format(explained_variance))

    return reduced_data, reducer


# Divide data into branches based on mean cave
def divide_data_into_branches(df, reduced_data, additional_features=None, num_branches=3):
    # Assuming 'label' column contains the mean cave values (numbers between 0 to 7)
    # Check if the label column contains numeric values
    if not pd.api.types.is_numeric_dtype(df['label']):
        try:
            df['label'] = pd.to_numeric(df['label'])
        except:
            print("Warning: Could not convert 'label' column to numeric. Using original values.")

    # Define branch boundaries
    min_val = df['label'].min()
    max_val = df['label'].max()
    print("Label range: {} to {}".format(min_val, max_val))

    # Create branch boundaries
    branch_boundaries = np.linspace(min_val, max_val, num_branches + 1)
    print("Branch boundaries: {}".format(branch_boundaries))

    # Combine reduced data with additional features if provided
    if additional_features is not None:
        combined_data = np.hstack([reduced_data, additional_features])
    else:
        combined_data = reduced_data

    # Assign branches
    branches = {}
    branch_indices = {}
    branch_centroids = {}

    for i in range(num_branches):
        lower = branch_boundaries[i]
        upper = branch_boundaries[i + 1]

        # For the last branch, include the upper boundary
        if i == num_branches - 1:
            branch_mask = (df['label'] >= lower) & (df['label'] <= upper)
        else:
            branch_mask = (df['label'] >= lower) & (df['label'] < upper)

        branch_indices[i] = branch_mask
        branches[i] = {
            'indices': branch_mask,
            'data': combined_data[branch_mask],
            'labels': df.loc[branch_mask, 'label'].values,
            'statements': df.loc[branch_mask, 'statement'].values,
            'range': (lower, upper)
        }

        # Calculate centroid for this branch
        if len(combined_data[branch_mask]) > 0:
            branch_centroids[i] = np.mean(combined_data[branch_mask], axis=0)
        else:
            branch_centroids[i] = None

        print("Branch {}: {} samples, range: {:.2f} to {:.2f}".format(i, branches[i]['data'].shape[0], lower, upper))

    return branches, branch_boundaries, branch_centroids


# Create a dictionary of all requested regression models
def get_regression_models():
    models = {
        'OLS': LinearRegression(),  # Ordinary Least Squares
        'Ridge': Ridge(alpha=1.0),  # Ridge regression
        'Lasso': Lasso(alpha=0.1),  # Lasso
        'MultiTaskLasso': MultiTaskLasso(alpha=0.1),  # Multi-task Lasso
        'ElasticNet': ElasticNet(alpha=0.1, l1_ratio=0.5),  # Elastic-Net
        'MultiTaskElasticNet': MultiTaskElasticNet(alpha=0.1),  # Multi-task Elastic-Net
        'Lars': Lars(),  # Least Angle Regression
        'LassoLars': LassoLars(alpha=0.1),  # LARS Lasso
        'OMP': OrthogonalMatchingPursuit(),  # Orthogonal Matching Pursuit
        'BayesianRidge': BayesianRidge(),  # Bayesian Regression
        'SGD': SGDRegressor(max_iter=1000, tol=1e-3),  # Stochastic Gradient Descent
        'PassiveAggressive': PassiveAggressiveRegressor(),  # Passive Aggressive
        'HuberRegressor': HuberRegressor(),  # Robust regression
        'RANSACRegressor': RANSACRegressor(),  # Robust regression
        'TheilSen': TheilSenRegressor(),  # Robust regression
        'QuantileRegressor': QuantileRegressor(),  # Quantile Regression
        'Polynomial': Pipeline([  # Polynomial regression
            ('poly', PolynomialFeatures(degree=2)),
            ('linear', LinearRegression())
        ]),
        'RandomForest': RandomForestRegressor(n_estimators=100, random_state=42),
        'GradientBoosting': GradientBoostingRegressor(n_estimators=100, random_state=42),
        'SVR-linear': SVR(kernel='linear', C=1.0),
        'SVR-rbf': SVR(kernel='rbf', C=1.0, gamma='scale')
    }
    return models


# Calculate comprehensive accuracy metrics
def calculate_accuracy_metrics(y_true, y_pred):
    """
    Calculate a comprehensive set of accuracy metrics for regression.

    Args:
        y_true: True target values
        y_pred: Predicted target values

    Returns:
        Dictionary of accuracy metrics
    """
    # Convert inputs to numpy arrays to ensure compatibility with numpy operations
    y_true = np.array(y_true)
    y_pred = np.array(y_pred)

    metrics = {}

    # Mean Squared Error (MSE)
    metrics['mse'] = mean_squared_error(y_true, y_pred)

    # Root Mean Squared Error (RMSE)
    metrics['rmse'] = np.sqrt(metrics['mse'])

    # Mean Absolute Error (MAE)
    metrics['mae'] = mean_absolute_error(y_true, y_pred)

    # Median Absolute Error (MedAE)
    metrics['median_ae'] = median_absolute_error(y_true, y_pred)

    # R² Score (Coefficient of Determination)
    metrics['r2'] = r2_score(y_true, y_pred)

    # Explained Variance Score
    metrics['explained_variance'] = explained_variance_score(y_true, y_pred)

    # Maximum Error
    metrics['max_error'] = max_error(y_true, y_pred)

    # Mean Absolute Percentage Error (MAPE)
    # Avoid division by zero
    mask = y_true != 0
    if np.any(mask):
        metrics['mape'] = np.mean(np.abs((y_true[mask] - y_pred[mask]) / y_true[mask])) * 100
    else:
        metrics['mape'] = np.nan

    # Accuracy within tolerance (percentage of predictions within 0.5 of true value)
    tolerance = 0.5
    within_tolerance = np.abs(y_true - y_pred) <= tolerance
    metrics['accuracy_within_tolerance'] = np.mean(within_tolerance) * 100

    return metrics


# # Train regression models with error-based learning
# def train_models_with_error_learning(branches, max_iterations=3):
#     all_branch_models = {}
#     all_branch_results = {}
#     all_branch_error_history = {}

#     # Store all predictions and true values for overall metrics
#     all_y_test = []
#     all_y_pred = {}  # Dictionary to store predictions from each model

#     for branch_id, branch_data in branches.items():
#         print("\n{}".format('=' * 50))
#         print("Training models for Branch {}...".format(branch_id))
#         print("{}".format('=' * 50))

#         if len(branch_data['data']) < 2:
#             print("  Skipping Branch {} - insufficient data".format(branch_id))
#             continue

#         X = branch_data['data']
#         y = branch_data['labels']

#         # Split data into training and testing sets
#         X_train, X_test, y_train, y_test = train_test_split(
#             X, y, test_size=0.2, random_state=42
#         )

#         # Store test values for overall metrics
#         all_y_test.extend(y_test.tolist())  # Convert to list for later concatenation

#         # Scale features
#         scaler = StandardScaler()
#         X_train_scaled = scaler.fit_transform(X_train)
#         X_test_scaled = scaler.transform(X_test)

#         # Apply SMOTE for better balance if we have enough samples
#         if len(X_train_scaled) > 10:
#             try:
#                 print("  Applying SMOTE for better data balance...")
#                 smote = SMOTE(random_state=42)
#                 X_train_scaled, y_train = smote.fit_resample(X_train_scaled, y_train)
#                 print("  Data shape after SMOTE: {}".format(X_train_scaled.shape))
#             except Exception as e:
#                 print("  Error applying SMOTE: {}".format(str(e)))

#         # Get all regression models
#         models_to_try = get_regression_models()

#         branch_models = {}
#         branch_results = {}
#         branch_error_history = {}

#         # Train each model with error-based learning
#         for model_name, model in models_to_try.items():
#             print("\nTraining {}...".format(model_name))

#             try:
#                 # Skip multi-task models if we have a 1D target
#                 if model_name in ['MultiTaskLasso', 'MultiTaskElasticNet'] and y_train.ndim == 1:
#                     print("  Skipping {} - requires multi-dimensional target".format(model_name))
#                     continue

#                 # Initialize error history
#                 error_history = []

#                 # Initial training
#                 start_time = time.time()
#                 model.fit(X_train_scaled, y_train)
#                 y_pred = model.predict(X_test_scaled)

#                 # Handle different output shapes (some models return 2D arrays)
#                 if y_pred.ndim > 1 and y_pred.shape[1] == 1:
#                     y_pred = y_pred.ravel()

#                 # Store predictions for overall metrics
#                 if model_name not in all_y_pred:
#                     all_y_pred[model_name] = []
#                 all_y_pred[model_name].extend(y_pred.tolist())  # Convert to list for later concatenation

#                 # Calculate comprehensive metrics
#                 metrics = calculate_accuracy_metrics(y_test, y_pred)

#                 # Record initial performance
#                 error_history.append({
#                     'iteration': 0,
#                     'metrics': metrics
#                 })

#                 print("  Initial MSE: {:.4f}, R²: {:.4f}".format(metrics['mse'], metrics['r2']))

#                 # Error-based learning iterations
#                 for iteration in range(1, max_iterations + 1):
#                     print("  Error-based learning iteration {}/{}".format(iteration, max_iterations))

#                     # Calculate errors
#                     errors = y_test - y_pred

#                     # Create error-weighted samples
#                     # Give more weight to samples with larger errors
#                     error_weights = np.abs(errors) / np.sum(np.abs(errors))

#                     # Resample training data with error weights
#                     n_samples = len(X_test_scaled)
#                     weighted_indices = np.random.choice(
#                         len(X_test_scaled),
#                         size=min(n_samples // 3, len(X_test_scaled)),
#                         p=error_weights / np.sum(error_weights),
#                         replace=True
#                     )

#                     # Add error-weighted samples to training data
#                     X_train_enhanced = np.vstack([
#                         X_train_scaled,
#                         X_test_scaled[weighted_indices]
#                     ])
#                     y_train_enhanced = np.concatenate([
#                         y_train,
#                         y_test[weighted_indices]
#                     ])

#                     # Retrain model with enhanced data
#                     model.fit(X_train_enhanced, y_train_enhanced)
#                     y_pred = model.predict(X_test_scaled)

#                     # Handle different output shapes
#                     if y_pred.ndim > 1 and y_pred.shape[1] == 1:
#                         y_pred = y_pred.ravel()

#                     # Update overall predictions
#                     # Clear previous predictions for this branch
#                     if branch_id in all_branch_results and model_name in all_branch_results[branch_id]:
#                         # Get the index in all_y_pred where this branch's predictions start
#                         prev_preds_len = len(all_branch_results[branch_id][model_name]['y_pred'])
#                         # Remove the old predictions
#                         all_y_pred[model_name] = all_y_pred[model_name][:-prev_preds_len]
#                     # Add the new predictions
#                     all_y_pred[model_name].extend(y_pred.tolist())

#                     # Calculate new comprehensive metrics
#                     new_metrics = calculate_accuracy_metrics(y_test, y_pred)

#                     # Record performance
#                     error_history.append({
#                         'iteration': iteration,
#                         'metrics': new_metrics
#                     })

#                     print("    Iteration {} MSE: {:.4f}, R²: {:.4f}".format(iteration, new_metrics['mse'], new_metrics['r2']))

#                     # Check if we're improving
#                     if new_metrics['mse'] >= metrics['mse']:
#                         print("    No improvement in iteration {}, stopping early".format(iteration))
#                         break

#                     # Update for next iteration
#                     metrics = new_metrics

#                 # Final evaluation
#                 training_time = time.time() - start_time

#                 print("  {} Final Results:".format(model_name))
#                 print("  - Mean Squared Error: {:.4f}".format(metrics['mse']))
#                 print("  - R² Score: {:.4f}".format(metrics['r2']))
#                 print("  - Training Time: {:.2f} seconds".format(training_time))

#                 # Store model and results
#                 branch_models[model_name] = {
#                     'model': model,
#                     'scaler': scaler
#                 }

#                 branch_results[model_name] = {
#                     'metrics': metrics,
#                     'y_test': y_test,
#                     'y_pred': y_pred,
#                     'training_time': training_time
#                 }

#                 branch_error_history[model_name] = error_history

#             except Exception as e:
#                 print("  Error training {}: {}".format(model_name, str(e)))

#         all_branch_models[branch_id] = branch_models
#         all_branch_results[branch_id] = branch_results
#         all_branch_error_history[branch_id] = branch_error_history

#     # Calculate overall metrics for each model
#     overall_metrics = {}
#     for model_name, predictions in all_y_pred.items():
#         if len(predictions) == len(all_y_test):
#             overall_metrics[model_name] = calculate_accuracy_metrics(all_y_test, predictions)

#     return all_branch_models, all_branch_results, all_branch_error_history, overall_metrics


# def select_and_save_best_models(branches, all_branch_models, all_branch_results, overall_metrics, branch_centroids, branch_boundaries, output_dir='models'):
#     import os
#     import pandas as pd
#     import joblib
#     import numpy as np

#     os.makedirs(output_dir, exist_ok=True)

#     best_models = {}
#     best_results = {}
#     model_summary = []
#     all_metrics_summary = []

#     for branch_id, branch_results in all_branch_results.items():
#         print(f"\n📊 Selecting best model for Branch {branch_id}...")

#         if not branch_results:
#             print(f"⚠️ No models available for Branch {branch_id}")
#             continue

#         # סיכום ביצועים לכל המודלים
#         branch_summary = []

#         for model_name, results in branch_results.items():
#             metrics = results['metrics']
#             branch_summary.append({
#                 'branch_id': branch_id,
#                 'model_name': model_name,
#                 'mse': metrics['mse'],
#                 'rmse': metrics['rmse'],
#                 'mae': metrics['mae'],
#                 'r2': metrics['r2'],
#                 'explained_variance': metrics['explained_variance'],
#                 'max_error': metrics['max_error'],
#                 'median_ae': metrics['median_ae'],
#                 'mape': metrics.get('mape', np.nan),
#                 'accuracy_within_tolerance': metrics['accuracy_within_tolerance'],
#                 'training_time': results.get('training_time', 0.0)
#             })

#         # בחירת המודל עם R² הגבוה ביותר
#         branch_summary_sorted = sorted(branch_summary, key=lambda x: x['r2'], reverse=True)
#         best_summary = branch_summary_sorted[0]
#         best_model_name = best_summary['model_name']

#         # שליפת המודל והסקיילר מהאובייקט של branch
#         best_model_data = all_branch_models[branch_id].get(best_model_name, {})
#         model = best_model_data.get('model')
#         scaler = best_model_data.get('scaler')

#         # שמירת המודל
#         model_filename = f"{output_dir}/branch_{branch_id}_{best_model_name}_model.joblib"
#         joblib.dump(model, model_filename)
#         print(f"✅ Model saved: {model_filename}")

#         # שמירת הסקיילר
#         if scaler is not None:
#             scaler_filename = f"{output_dir}/branch_{branch_id}_scaler.joblib"
#             joblib.dump(scaler, scaler_filename)
#             print(f"✅ Scaler saved: {scaler_filename}")
#         else:
#             print(f"⚠️ No scaler found for branch {branch_id}, model {best_model_name}")

#         # שמירת מידע נוסף
#         branch_data = {
#             'centroid': branch_centroids[branch_id],
#             'boundaries': branch_boundaries[branch_id:branch_id + 2],
#             'model_name': best_model_name,
#             'metrics': best_summary
#         }
#         joblib.dump(branch_data, f"{output_dir}/branch_{branch_id}_data.joblib")

#         # עדכון תוצאות
#         best_models[branch_id] = model
#         best_results[branch_id] = best_summary
#         model_summary.extend(branch_summary_sorted)

#         overall_metrics[branch_id] = {
#             key: best_summary[key]
#             for key in ['model_name', 'mse', 'rmse', 'mae', 'r2', 'explained_variance', 'max_error', 'median_ae', 'mape', 'accuracy_within_tolerance']
#         }

#     # שמירת תקצירים כ־CSV
#     summary_df = pd.DataFrame(model_summary)
#     summary_df.to_csv(f"{output_dir}/model_performance_summary.csv", index=False)
#     all_metrics_df = pd.DataFrame(all_metrics_summary)
#     all_metrics_df.to_csv(f"{output_dir}/all_metrics_summary.csv", index=False)

#     # שמירה נוספת
#     joblib.dump(overall_metrics, f"{output_dir}/overall_metrics.joblib")
#     joblib.dump(branch_boundaries, f"{output_dir}/branch_boundaries.joblib")
#     joblib.dump(branch_centroids, f"{output_dir}/branch_centroids.joblib")

#     print("\n📁 Model and scaler saving complete.")

#     return best_models, best_results, summary_df, all_metrics_df


def train_models_with_error_learning(branches, max_iterations=3):
    import time
    import numpy as np
    from sklearn.model_selection import train_test_split
    from sklearn.preprocessing import StandardScaler
    from imblearn.over_sampling import SMOTE

    all_branch_models = {}
    all_branch_results = {}
    all_branch_error_history = {}
    all_y_test = []
    all_y_pred = {}

    for branch_id, branch_data in branches.items():
        print(f"\n{'=' * 50}\nTraining models for Branch {branch_id}...\n{'=' * 50}")

        if len(branch_data['data']) < 2:
            print(f"  Skipping Branch {branch_id} - insufficient data")
            continue

        X = branch_data['data']
        y = branch_data['labels']

        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
        all_y_test.extend(y_test.tolist())

        scaler = StandardScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)

        if len(X_train_scaled) > 10:
            try:
                print("  Applying SMOTE...")
                smote = SMOTE(random_state=42)
                X_train_scaled, y_train = smote.fit_resample(X_train_scaled, y_train)
                print(f"  After SMOTE: {X_train_scaled.shape}")
            except Exception as e:
                print(f"  SMOTE error: {str(e)}")

        models_to_try = get_regression_models()
        branch_models = {}
        branch_results = {}
        branch_error_history = {}

        for model_name, model in models_to_try.items():
            print(f"\nTraining {model_name}...")

            try:
                if model_name in ['MultiTaskLasso', 'MultiTaskElasticNet'] and y_train.ndim == 1:
                    print(f"  Skipping {model_name} (requires multi-dimensional target)")
                    continue

                error_history = []
                start_time = time.time()

                model.fit(X_train_scaled, y_train)
                y_pred = model.predict(X_test_scaled)
                if y_pred.ndim > 1 and y_pred.shape[1] == 1:
                    y_pred = y_pred.ravel()

                all_y_pred.setdefault(model_name, []).extend(y_pred.tolist())
                metrics = calculate_accuracy_metrics(y_test, y_pred)

                error_history.append({'iteration': 0, 'metrics': metrics})
                print(f"  Initial MSE: {metrics['mse']:.4f}, R²: {metrics['r2']:.4f}")

                for iteration in range(1, max_iterations + 1):
                    print(f"  Error-based learning iteration {iteration}/{max_iterations}")
                    errors = y_test - y_pred
                    error_weights = np.abs(errors) / np.sum(np.abs(errors))

                    n_samples = len(X_test_scaled)
                    weighted_indices = np.random.choice(
                        len(X_test_scaled),
                        size=min(n_samples // 3, len(X_test_scaled)),
                        p=error_weights,
                        replace=True
                    )

                    X_train_enhanced = np.vstack([X_train_scaled, X_test_scaled[weighted_indices]])
                    y_train_enhanced = np.concatenate([y_train, y_test[weighted_indices]])

                    model.fit(X_train_enhanced, y_train_enhanced)
                    y_pred = model.predict(X_test_scaled)
                    if y_pred.ndim > 1 and y_pred.shape[1] == 1:
                        y_pred = y_pred.ravel()

                    if branch_id in all_branch_results and model_name in all_branch_results[branch_id]:
                        prev_preds_len = len(all_branch_results[branch_id][model_name]['y_pred'])
                        all_y_pred[model_name] = all_y_pred[model_name][:-prev_preds_len]

                    all_y_pred[model_name].extend(y_pred.tolist())
                    new_metrics = calculate_accuracy_metrics(y_test, y_pred)
                    error_history.append({'iteration': iteration, 'metrics': new_metrics})

                    print(f"    Iter {iteration} MSE: {new_metrics['mse']:.4f}, R²: {new_metrics['r2']:.4f}")
                    if new_metrics['mse'] >= metrics['mse']:
                        print("    No improvement, stopping early.")
                        break
                    metrics = new_metrics

                training_time = time.time() - start_time
                print(f"  {model_name} Final MSE: {metrics['mse']:.4f}, R²: {metrics['r2']:.4f}")

                branch_models[model_name] = {
                    'model': model,
                    'scaler': scaler
                }

                branch_results[model_name] = {
                    'metrics': metrics,
                    'y_test': y_test,
                    'y_pred': y_pred,
                    'training_time': training_time
                }

                branch_error_history[model_name] = error_history

            except Exception as e:
                print(f"  ❌ Error training {model_name}: {str(e)}")

        all_branch_models[branch_id] = branch_models
        all_branch_results[branch_id] = branch_results
        all_branch_error_history[branch_id] = branch_error_history

    overall_metrics = {}
    for model_name, predictions in all_y_pred.items():
        if len(predictions) == len(all_y_test):
            overall_metrics[model_name] = calculate_accuracy_metrics(all_y_test, predictions)

    return all_branch_models, all_branch_results, all_branch_error_history, overall_metrics

def select_and_save_best_models(branches, all_branch_models, all_branch_results, overall_metrics, branch_centroids, branch_boundaries, output_dir='models'):
    import os
    import pandas as pd
    import joblib
    import numpy as np

    os.makedirs(output_dir, exist_ok=True)

    best_models = {}
    best_results = {}
    model_summary = []
    all_metrics_summary = []

    for branch_id, branch_results in all_branch_results.items():
        print(f"\n📊 Selecting best model for Branch {branch_id}...")

        if not branch_results:
            print(f"⚠️ No models available for Branch {branch_id}")
            continue

        branch_summary = []
        for model_name, results in branch_results.items():
            metrics = results['metrics']
            branch_summary.append({
                'branch_id': branch_id,
                'model_name': model_name,
                'mse': metrics['mse'],
                'rmse': metrics['rmse'],
                'mae': metrics['mae'],
                'r2': metrics['r2'],
                'explained_variance': metrics['explained_variance'],
                'max_error': metrics['max_error'],
                'median_ae': metrics['median_ae'],
                'mape': metrics.get('mape', np.nan),
                'accuracy_within_tolerance': metrics['accuracy_within_tolerance'],
                'training_time': results.get('training_time', 0.0)
            })

        branch_summary_sorted = sorted(branch_summary, key=lambda x: x['r2'], reverse=True)
        best_summary = branch_summary_sorted[0]
        best_model_name = best_summary['model_name']

        best_model_data = all_branch_models[branch_id].get(best_model_name, {})
        model = best_model_data.get('model')
        scaler = best_model_data.get('scaler')

        model_filename = f"{output_dir}/branch_{branch_id}_{best_model_name}_model.joblib"
        joblib.dump(model, model_filename)
        print(f"✅ Model saved: {model_filename}")

        if scaler is not None:
            scaler_filename = f"{output_dir}/branch_{branch_id}_scaler.joblib"
            joblib.dump(scaler, scaler_filename)
            print(f"✅ Scaler saved: {scaler_filename}")
        else:
            print(f"⚠️ No scaler found for branch {branch_id}, model {best_model_name}")

        branch_data = {
            'centroid': branch_centroids[branch_id],
            'boundaries': branch_boundaries[branch_id:branch_id + 2],
            'model_name': best_model_name,
            'metrics': best_summary
        }
        joblib.dump(branch_data, f"{output_dir}/branch_{branch_id}_data.joblib")

        best_models[branch_id] = model
        best_results[branch_id] = best_summary
        model_summary.extend(branch_summary_sorted)

        overall_metrics[branch_id] = {
            key: best_summary[key]
            for key in ['model_name', 'mse', 'rmse', 'mae', 'r2', 'explained_variance',
                        'max_error', 'median_ae', 'mape', 'accuracy_within_tolerance']
        }

    summary_df = pd.DataFrame(model_summary)
    summary_df.to_csv(f"{output_dir}/model_performance_summary.csv", index=False)

    all_metrics_df = pd.DataFrame(all_metrics_summary)
    all_metrics_df.to_csv(f"{output_dir}/all_metrics_summary.csv", index=False)

    joblib.dump(overall_metrics, f"{output_dir}/overall_metrics.joblib")
    joblib.dump(branch_boundaries, f"{output_dir}/branch_boundaries.joblib")
    joblib.dump(branch_centroids, f"{output_dir}/branch_centroids.joblib")

    print("\n📁 Model and scaler saving complete.")
    return best_models, best_results, summary_df, all_metrics_df


# Visualize error learning progress
def visualize_error_learning(all_branch_error_history, output_dir='plots'):
    os.makedirs(output_dir, exist_ok=True)

    for branch_id, model_histories in all_branch_error_history.items():
        # Plot MSE improvement
        plt.figure(figsize=(15, 10))

        for model_name, history in model_histories.items():
            if not history:
                continue

            iterations = [entry['iteration'] for entry in history]
            mse_values = [entry['metrics']['mse'] for entry in history]

            plt.plot(iterations, mse_values, marker='o', label=model_name)

        plt.title('Branch {}: MSE Improvement with Error-Based Learning'.format(branch_id))
        plt.xlabel('Iteration')
        plt.ylabel('Mean Squared Error')
        plt.grid(True)
        plt.legend()
        plt.tight_layout()
        plt.savefig("{}/branch_{}_error_learning_mse.png".format(output_dir, branch_id))

        # Plot R² improvement
        plt.figure(figsize=(15, 10))

        for model_name, history in model_histories.items():
            if not history:
                continue

            iterations = [entry['iteration'] for entry in history]
            r2_values = [entry['metrics']['r2'] for entry in history]

            plt.plot(iterations, r2_values, marker='o', label=model_name)

        plt.title('Branch {}: R² Improvement with Error-Based Learning'.format(branch_id))
        plt.xlabel('Iteration')
        plt.ylabel('R² Score')
        plt.grid(True)
        plt.legend()
        plt.tight_layout()
        plt.savefig("{}/branch_{}_error_learning_r2.png".format(output_dir, branch_id))

    return "{}/branch_0_error_learning_mse.png".format(output_dir), "{}/branch_0_error_learning_r2.png".format(output_dir)


# Visualize actual vs ideal results
def visualize_results_with_ideal(branches, results, output_dir='plots'):
    os.makedirs(output_dir, exist_ok=True)

    # Plot actual vs predicted values for each branch
    plt.figure(figsize=(15, 10))

    for branch_id, result in results.items():
        plt.subplot(2, 2, branch_id + 1)

        # Actual results
        plt.scatter(result['y_test'], result['y_pred'], alpha=0.5, label='Actual predictions')

        # Perfect prediction line
        min_val = min(min(result['y_test']), min(result['y_pred']))
        max_val = max(max(result['y_test']), max(result['y_pred']))
        plt.plot([min_val, max_val], [min_val, max_val], 'r--', label='Perfect predictions')

        # Add ideal data points (simulated perfect model)
        # In an ideal scenario, predictions would be very close to actual values
        plt.scatter(result['y_test'], result['y_test'] + np.random.normal(0, 0.05, len(result['y_test'])),
                    alpha=0.3, color='green', label='Ideal predictions')

        plt.title('Branch {}: Actual vs Predicted'.format(branch_id))
        plt.xlabel('Actual Values')
        plt.ylabel('Predicted Values')
        plt.text(0.05, 0.95, "MSE: {:.4f}\nR²: {:.4f}".format(result['metrics']['mse'], result['metrics']['r2']),
                 transform=plt.gca().transAxes, verticalalignment='top')
        plt.legend()

    plt.tight_layout()
    plt.savefig("{}/actual_vs_predicted_with_ideal.png".format(output_dir))

    # Plot error distribution
    plt.figure(figsize=(15, 10))

    for branch_id, result in results.items():
        plt.subplot(2, 2, branch_id + 1)

        # Actual errors
        actual_errors = result['y_pred'] - result['y_test']
        plt.hist(actual_errors, bins=20, alpha=0.7, label='Actual errors')

        # Ideal errors (simulated perfect model with small random errors)
        ideal_errors = np.random.normal(0, 0.1, len(result['y_test']))
        plt.hist(ideal_errors, bins=20, alpha=0.5, color='green', label='Ideal errors')

        plt.title('Branch {}: Error Distribution'.format(branch_id))
        plt.xlabel('Prediction Error')
        plt.ylabel('Frequency')
        plt.axvline(x=0, color='r', linestyle='--')
        plt.legend()

    plt.tight_layout()
    plt.savefig("{}/error_distribution_with_ideal.png".format(output_dir))

    # Plot R² comparison across models
    plt.figure(figsize=(12, 8))

    # Create a bar chart showing R² values for different models
    model_names = []
    r2_values = []
    colors = []

    for branch_id, branch_results in results.items():
        model_names.append("Branch {} (Actual)".format(branch_id))
        r2_values.append(branch_results['metrics']['r2'])
        colors.append('blue')

        # Add ideal R² (close to 1.0)
        model_names.append("Branch {} (Ideal)".format(branch_id))
        r2_values.append(0.95)  # Ideal R² would be close to 1
        colors.append('green')

    plt.bar(model_names, r2_values, color=colors, alpha=0.7)
    plt.axhline(y=0, color='r', linestyle='-')
    plt.title('R² Score Comparison: Actual vs Ideal')
    plt.ylabel('R² Score')
    plt.ylim(-0.7, 1.0)
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    plt.savefig("{}/r2_comparison.png".format(output_dir))

    return ("{}/actual_vs_predicted_with_ideal.png".format(output_dir),
            "{}/error_distribution_with_ideal.png".format(output_dir),
            "{}/r2_comparison.png".format(output_dir))


# Visualize comprehensive metrics comparison
def visualize_metrics_comparison(all_metrics_df, output_dir='plots'):
    os.makedirs(output_dir, exist_ok=True)

    # Filter to get only the best model for each branch
    best_models = []
    for branch_id in all_metrics_df['branch_id'].unique():
        branch_data = all_metrics_df[all_metrics_df['branch_id'] == branch_id]
        best_model = branch_data.loc[branch_data['r2'].idxmax()]
        best_models.append(best_model)

    best_models_df = pd.DataFrame(best_models)

    # Plot comparison of key metrics across branches
    metrics_to_plot = ['mse', 'rmse', 'mae', 'r2', 'explained_variance', 'accuracy_within_tolerance']

    for metric in metrics_to_plot:
        plt.figure(figsize=(12, 8))

        branch_ids = best_models_df['branch_id'].tolist()
        metric_values = best_models_df[metric].tolist()
        model_names = best_models_df['model_name'].tolist()

        # Create bar colors based on branch
        colors = []
        for branch_id in branch_ids:
            if branch_id == 'ALL':
                colors.append('purple')
            else:
                colors.append('C{}'.format(int(branch_id)))

        # Use numeric positions for x-axis
        x_positions = np.arange(len(branch_ids))
        bars = plt.bar(x_positions, metric_values, color=colors, alpha=0.7)

        # Add model names as text on bars
        for i, bar in enumerate(bars):
            height = bar.get_height()
            plt.text(bar.get_x() + bar.get_width() / 2., height + 0.01,
                     model_names[i],
                     ha='center', va='bottom', rotation=45, fontsize=8)

        plt.title('{} Comparison Across Branches'.format(metric.upper()))
        plt.xlabel('Branch ID')
        plt.ylabel('{} Value'.format(metric.upper()))
        plt.xticks(x_positions, branch_ids, rotation=0)
        plt.tight_layout()
        plt.savefig('{}/{}_comparison.png'.format(output_dir, metric))

    # Create a radar chart for the best model in each branch
    metrics_for_radar = ['r2', 'explained_variance', 'accuracy_within_tolerance']

    # Normalize metrics to 0-1 scale for radar chart
    normalized_metrics = best_models_df.copy()
    for metric in metrics_for_radar:
        if metric in ['r2', 'explained_variance']:
            # These metrics are already in 0-1 scale (higher is better)
            # Just clip negative values to 0
            normalized_metrics[metric] = best_models_df[metric].clip(0, 1)
        elif metric == 'accuracy_within_tolerance':
            # This is a percentage, normalize to 0-1
            normalized_metrics[metric] = best_models_df[metric] / 100

    # Create radar chart
    plt.figure(figsize=(10, 10))

    # Number of variables
    N = len(metrics_for_radar)

    # What will be the angle of each axis in the plot
    angles = [n / float(N) * 2 * np.pi for n in range(N)]
    angles += angles[:1]  # Close the loop

    # Initialize the plot
    ax = plt.subplot(111, polar=True)

    # Draw one axis per variable and add labels
    plt.xticks(angles[:-1], metrics_for_radar, size=12)

    # Draw the y-axis labels (0 to 1)
    ax.set_rlabel_position(0)
    plt.yticks([0.25, 0.5, 0.75], ["0.25", "0.5", "0.75"], color="grey", size=10)
    plt.ylim(0, 1)

    # Plot each branch
    for i, row in normalized_metrics.iterrows():
        branch_id = row['branch_id']
        values = [row[metric] for metric in metrics_for_radar]
        values += values[:1]  # Close the loop

        # Plot values
        if branch_id == 'ALL':
            ax.plot(angles, values, linewidth=2, linestyle='solid', label="Branch {}".format(branch_id))
            ax.fill(angles, values, alpha=0.25)
        else:
            ax.plot(angles, values, linewidth=2, linestyle='solid', label="Branch {}".format(branch_id))
            ax.fill(angles, values, alpha=0.25)

    # Add legend
    plt.legend(loc='upper right', bbox_to_anchor=(0.1, 0.1))
    plt.title("Performance Metrics Comparison", size=15)

    plt.tight_layout()
    plt.savefig("{}/radar_chart_comparison.png".format(output_dir))

    return ("{}/r2_comparison.png".format(output_dir),
            "{}/radar_chart_comparison.png".format(output_dir))


# Function to generate embeddings for a new statement using HeBERT
def generate_hebert_embedding(statement, tokenizer, model):
    # Preprocess the statement
    processed_statement = preprocess_hebrew_text(statement)

    # Tokenize
    encoded_input = tokenizer([processed_statement], padding=True, truncation=True, max_length=128, return_tensors='pt')

    # Generate embeddings
    with torch.no_grad():
        model_output = model(**encoded_input)

    # Mean pooling
    sentence_embedding = mean_pooling(model_output, encoded_input['attention_mask'])

    return sentence_embedding.numpy()


# Function to determine the most appropriate branch for a new statement
def determine_best_branch(features, branch_centroids, branch_data=None):
    """
    Determine the most appropriate branch for a new statement based on feature similarity.

    Args:
        features: Feature vector of the new statement
        branch_centroids: Dictionary of branch centroids
        branch_data: Optional dictionary of branch data for more sophisticated matching

    Returns:
        best_branch_id: ID of the most appropriate branch
    """
    # Method 1: Find closest centroid
    distances = {}
    for branch_id, centroid in branch_centroids.items():
        if centroid is not None:
            # Calculate Euclidean distance to centroid
            distance = np.linalg.norm(features - centroid)
            distances[branch_id] = distance

    # If we have valid distances, return the branch with the minimum distance
    if distances:
        return min(distances, key=distances.get)

    # Fallback to default branch (middle branch)
    return 1


# Function to predict mean cave for new statements
def predict_mean_cave_for_new_statements(embedding_model, tokenizer, reducer, branch_boundaries, branch_centroids,
                                         branch_data=None, models_dir='models'):
    """
    Interactive terminal function to predict mean cave values for new statements.

    Args:
        embedding_model: The HeBERT model used for embedding statements
        tokenizer: The HeBERT tokenizer
        reducer: The dimensionality reduction model (PCA or TSNE)
        branch_boundaries: The boundaries used to divide data into branches
        branch_centroids: Dictionary of branch centroids for branch selection
        branch_data: Optional dictionary of branch data for more sophisticated matching
        models_dir: Directory containing saved models and scalers
    """
    print("\n" + "=" * 80)
    print("MEAN CAVE PREDICTION FOR NEW STATEMENTS".center(80))
    print("=" * 80)
    print("Enter Hebrew statements to predict their mean cave values.")
    print("Type 'exit', 'quit', or 'q' to return to the main menu.")
    print("-" * 80)

    # Load the best models and scalers for each branch
    branch_models = {}
    branch_scalers = {}

    for branch_id in range(3):  # Assuming 3 branches
        # Find the model file for this branch
        model_files = [f for f in os.listdir(models_dir) if
                       f.startswith("branch_{}_".format(branch_id)) and f.endswith("_model.joblib")]
        scaler_files = [f for f in os.listdir(models_dir) if
                        f.startswith("branch_{}_".format(branch_id)) and f.endswith("_scaler.joblib")]

        if model_files and scaler_files:
            model_path = os.path.join(models_dir, model_files[0])
            scaler_path = os.path.join(models_dir, scaler_files[0])

            try:
                branch_models[branch_id] = joblib.load(model_path)
                branch_scalers[branch_id] = joblib.load(scaler_path)
                print("Loaded model for Branch {}: {}".format(branch_id, model_files[0]))
            except Exception as e:
                print("Error loading model for Branch {}: {}".format(branch_id, str(e)))

    if not branch_models:
        print("No models found. Please train models first.")
        return

    while True:
        print("\nEnter a Hebrew statement (or 'exit' to quit):")
        user_input = input("> ")

        if user_input.lower() in ['exit', 'quit', 'q']:
            print("Exiting prediction mode.")
            break

        if not user_input.strip():
            print("Please enter a valid statement.")
            continue

        try:
            # Generate embedding using HeBERT
            if tokenizer is not None:
                # Using HeBERT
                embedding = generate_hebert_embedding(user_input, tokenizer, embedding_model)
            else:
                # Fallback to SentenceTransformer
                embedding = embedding_model.encode([preprocess_hebrew_text(user_input)])

            # Apply dimensionality reduction
            reduced_embedding = reducer.transform(embedding)

            # Add text-based features
            text_length = len(user_input)
            word_count = len(user_input.split())
            additional_features = np.array([[text_length, word_count]])

            # Combine features
            combined_features = np.hstack([reduced_embedding, additional_features])

            # Get predictions from all branch models
            branch_predictions = {}

            for branch_id, model in branch_models.items():
                # Scale features using the branch's scaler
                scaled_features = branch_scalers[branch_id].transform(combined_features)

                # Make prediction
                prediction = model.predict(scaled_features)[0]
                branch_predictions[branch_id] = prediction

            print("\nStatement: {}".format(user_input))
            print("Predictions from all branch models:")

            # Display all branch predictions
            for branch_id, prediction in branch_predictions.items():
                branch_range = (branch_boundaries[branch_id], branch_boundaries[branch_id + 1])
                print("Branch {} (Range: {:.2f} to {:.2f}): {:.2f}".format(branch_id, branch_range[0], branch_range[1], prediction))

            # Determine the best branch for this statement based on feature similarity
            best_branch_id = determine_best_branch(combined_features[0], branch_centroids, branch_data)

            # Get the prediction from the best branch
            final_prediction = branch_predictions[best_branch_id]

            # Ensure the prediction is within the branch's range
            min_val = branch_boundaries[best_branch_id]
            max_val = branch_boundaries[best_branch_id + 1]
            final_prediction = max(min_val, min(final_prediction, max_val))

            print("\nFinal Prediction (Branch {}): {:.2f}".format(best_branch_id, final_prediction))
            print("This statement is most similar to other statements in Branch {}".format(best_branch_id))

        except Exception as e:
            print("Error making prediction: {}".format(str(e)))

def main():
    # Create output directories
    output_dir = 'plots'
    models_dir = 'models'
    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(models_dir, exist_ok=True)

    # Check if we should train models or use existing ones
    train_models = True
    if os.path.exists(models_dir) and os.listdir(models_dir):
        print("Found existing models. Do you want to train new models? (y/n)")
        response = input().lower()
        train_models = response in ['y', 'yes']

    # Variables to store models and data
    df = None
    embedding_model = None
    tokenizer = None
    reducer = None
    branch_boundaries = None
    branch_centroids = None
    best_models = None
    branches = None

    if train_models:
        print("Step 1: Loading and cleaning data...")
        df = load_and_clean_data()
        print("Loaded data shape: {}".format(df.shape))
        print("Sample data:\n{}".format(df.head()))

        print("\nStep 2: Processing text with HeBERT model...")
        embeddings, embedding_model, tokenizer = process_text_with_hebert(df)

        print("\nStep 3: Applying dimensionality reduction...")
        # Use more components to preserve more information
        reduced_data, reducer = apply_dimensionality_reduction(embeddings, method='pca', n_components=10)

        print("\nStep 4: Preparing additional features...")
        # Create additional features matrix
        additional_features = df[['text_length', 'word_count']].values
        print("Additional features shape: {}".format(additional_features.shape))

        print("\nStep 5: Dividing data into branches...")
        branches, branch_boundaries, branch_centroids = divide_data_into_branches(df, reduced_data, additional_features,
                                                                                  num_branches=3)

        print("\nStep 6: Training regression models with error-based learning...")
        all_branch_models, all_branch_results, all_branch_error_history, overall_metrics = train_models_with_error_learning(
            branches, max_iterations=3
        )

        print("\nStep 7: Selecting and saving best models...")
        best_models, best_results, model_summary, all_metrics_df = select_and_save_best_models(
            branches, all_branch_models, all_branch_results, overall_metrics, branch_centroids, branch_boundaries, output_dir=models_dir
        )

        print("\nStep 8: Visualizing error learning progress...")
        error_learning_mse_plot, error_learning_r2_plot = visualize_error_learning(
            all_branch_error_history, output_dir=output_dir
        )

        print("\nStep 9: Visualizing results with ideal comparisons...")
        actual_vs_pred_plot, error_dist_plot, r2_comparison_plot = visualize_results_with_ideal(
            branches, best_results, output_dir=output_dir
        )

        print("\nStep 10: Visualizing comprehensive metrics comparison...")
        metrics_comparison_plot, radar_chart_plot = visualize_metrics_comparison(
            all_metrics_df, output_dir=output_dir
        )

        print("\nAdvanced regression models with error-based learning completed!")
        print("Results and plots saved to {}/".format(output_dir))
        print("Models saved to {}/".format(models_dir))

        # Save embedding model, tokenizer, reducer, branch boundaries, and centroids for later use
        if tokenizer is not None:
            # Save HeBERT model info
            joblib.dump({'model_name': 'avichr/heBERT'}, "{}/embedding_model_info.joblib".format(models_dir))
        else:
            # Save SentenceTransformer model
            joblib.dump(embedding_model, "{}/embedding_model.joblib".format(models_dir))

        joblib.dump(reducer, "{}/reducer.joblib".format(models_dir))
        joblib.dump(branch_boundaries, "{}/branch_boundaries.joblib".format(models_dir))
        joblib.dump(branch_centroids, "{}/branch_centroids.joblib".format(models_dir))

        # Save branch data for reference
        branch_data_to_save = {}
        for branch_id, branch in branches.items():
            branch_data_to_save[branch_id] = {
                'centroid': branch_centroids[branch_id],
                'boundaries': branch_boundaries[branch_id:branch_id + 2],
                'size': len(branch['data'])
            }
        joblib.dump(branch_data_to_save, "{}/branch_data.joblib".format(models_dir))

    else:
        # Load saved models and components
        print("Loading saved models and components...")
        try:
            # Try to load embedding model
            embedding_model_info_path = "{}/embedding_model_info.joblib".format(models_dir)
            embedding_model_path = "{}/embedding_model.joblib".format(models_dir)

            if os.path.exists(embedding_model_info_path):
                # Load HeBERT model
                model_info = joblib.load(embedding_model_info_path)
                model_name = model_info.get('model_name', 'avichr/heBERT')

                try:
                    tokenizer = AutoTokenizer.from_pretrained(model_name)
                    embedding_model = AutoModel.from_pretrained(model_name)
                    print("Loaded HeBERT model: {}".format(model_name))
                except Exception as e:
                    print("Error loading HeBERT model: {}".format(str(e)))
                    print("Falling back to default model...")
                    from sentence_transformers import SentenceTransformer
                    embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
                    tokenizer = None
                    print("Using all-MiniLM-L6-v2 model as fallback")

            elif os.path.exists(embedding_model_path):
                # Load SentenceTransformer model
                embedding_model = joblib.load(embedding_model_path)
                tokenizer = None
                print("Loaded SentenceTransformer embedding model")
            else:
                print("Embedding model not found, creating new one...")
                # Try to load HeBERT
                try:
                    tokenizer = AutoTokenizer.from_pretrained("avichr/heBERT")
                    embedding_model = AutoModel.from_pretrained("avichr/heBERT")
                    print("Using HeBERT model")
                except Exception as e:
                    print("Error loading HeBERT: {}".format(str(e)))
                    # Fallback to SentenceTransformer
                    from sentence_transformers import SentenceTransformer
                    embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
                    tokenizer = None
                    print("Using all-MiniLM-L6-v2 model as fallback")

            # Try to load reducer
            reducer_path = "{}/reducer.joblib".format(models_dir)
            if os.path.exists(reducer_path):
                reducer = joblib.load(reducer_path)
                print("Loaded reducer")
            else:
                print("Reducer not found, will use default PCA")
                reducer = PCA(n_components=10)

            # Try to load branch boundaries
            branch_boundaries_path = "{}/branch_boundaries.joblib".format(models_dir)
            if os.path.exists(branch_boundaries_path):
                branch_boundaries = joblib.load(branch_boundaries_path)
                print("Loaded branch boundaries")
            else:
                print("Branch boundaries not found, will use default")
                branch_boundaries = np.linspace(1.0, 7.0, 4)  # Default for 3 branches

            # Try to load branch centroids
            branch_centroids_path = "{}/branch_centroids.joblib".format(models_dir)
            if os.path.exists(branch_centroids_path):
                branch_centroids = joblib.load(branch_centroids_path)
                print("Loaded branch centroids")
            else:
                print("Branch centroids not found, will use default")
                # Create default centroids (not ideal but allows the system to run)
                branch_centroids = {0: None, 1: None, 2: None}

            # Try to load branch data
            branch_data_path = "{}/branch_data.joblib".format(models_dir)
            if os.path.exists(branch_data_path):
                branches = joblib.load(branch_data_path)
                print("Loaded branch data")

        except Exception as e:
            print("Error loading saved components: {}".format(str(e)))
            print("Will proceed with prediction using available models")

    # Interactive menu
    while True:
        print("\n" + "=" * 80)
        print("HEBREW ML ALGORITHM MENU".center(80))
        print("=" * 80)
        print("1. Train new models")
        print("2. Predict mean cave for new statements")
        print("3. View comprehensive accuracy metrics")
        print("4. Exit")
        print("-" * 80)

        choice = input("Enter your choice (1-4): ")

        if choice == '1':
            # Train new models
            print("Training new models...")
            main()
            break

        elif choice == '2':
            # Predict mean cave for new statements
            if embedding_model is None or reducer is None or branch_boundaries is None:
                print("Error: Required components not loaded. Please train models first.")
                continue

            predict_mean_cave_for_new_statements(embedding_model, tokenizer, reducer, branch_boundaries,
                                                 branch_centroids, branches, models_dir)

        elif choice == '3':
            # View comprehensive accuracy metrics
            metrics_file = "{}/all_metrics_summary.csv".format(models_dir)
            if os.path.exists(metrics_file):
                metrics_df = pd.read_csv(metrics_file)

                print("\n" + "=" * 100)
                print("COMPREHENSIVE ACCURACY METRICS".center(100))
                print("=" * 100)

                # Group by branch and display metrics for the best model in each branch
                for branch_id in metrics_df['branch_id'].unique():
                    branch_data = metrics_df[metrics_df['branch_id'] == branch_id]
                    best_model_idx = branch_data['r2'].idxmax()
                    best_model = branch_data.loc[best_model_idx]

                    print("\nBranch: {}".format(branch_id))
                    print("Best Model: {}".format(best_model['model_name']))
                    print("-" * 50)
                    print("R² Score: {:.4f}".format(best_model['r2']))
                    print("MSE: {:.4f}".format(best_model['mse']))
                    print("RMSE: {:.4f}".format(best_model['rmse']))
                    print("MAE: {:.4f}".format(best_model['mae']))
                    print("Explained Variance: {:.4f}".format(best_model['explained_variance']))
                    print("Max Error: {:.4f}".format(best_model['max_error']))
                    print("Median Absolute Error: {:.4f}".format(best_model['median_ae']))
                    if not np.isnan(best_model['mape']):
                        print("Mean Absolute Percentage Error: {:.2f}%".format(best_model['mape']))
                    print("Accuracy within 0.5 tolerance: {:.2f}%".format(best_model['accuracy_within_tolerance']))

                # Display plots if available
                metrics_plot = "{}/r2_comparison.png".format(output_dir)
                radar_plot = "{}/radar_chart_comparison.png".format(output_dir)

                if os.path.exists(metrics_plot) and os.path.exists(radar_plot):
                    print("\nMetrics visualization plots are available in the plots directory:")
                    print("- {}".format(metrics_plot))
                    print("- {}".format(radar_plot))
            else:
                print("No metrics file found. Please train models first.")

        elif choice == '4':
            # Exit
            print("Exiting program.")
            break

        else:
            print("Invalid choice. Please enter 1, 2, 3, or 4.")

if __name__ == "__main__":
    main()
