
import uuid
import os

from .questionnaire.utils import choose_random_questions, evaluate_answers, load_questions_from_files
from flask import jsonify, request

from .config import (
    UPLOAD_FOLDER,
    TEMP_FOLDER,
    DEFAULT_FPS,
    VIDEO_OUTPUT_PATH,
    QUESTIONNAIRES,
    NUM_QUESTIONS
)

from .FrameExtractor import FrameExtractor

from deepface import DeepFace

from app import app

@app.route("/")
def index():
    return True


@app.route("/analyze", methods=["POST"])
def analyse_emotion():
    if "video" not in request.files:
        return jsonify({"error": "Missing files in request"}), 400

    vid = request.files["video"]
    fps = request.form.get("fps", DEFAULT_FPS)

    if not vid.filename:
        return jsonify({"error": "No file selected for uploading"}), 400

    if not vid.filename.endswith(".mp4"):
        return jsonify({"error": "Only mp4 files are allowed for uploading"}), 400

    os.makedirs(UPLOAD_FOLDER, exist_ok=True)
    unique_filename = f"{str(uuid.uuid4())[:8]}_{vid.filename.replace(' ', '_')}"
    vid.save(os.path.join(UPLOAD_FOLDER, unique_filename))

    frame_extractor = FrameExtractor(
        os.path.join(UPLOAD_FOLDER, unique_filename))
    temp_dir = frame_extractor.extract_frames(TEMP_FOLDER, fps)

    objs = DeepFace.analyze(os.path.join(TEMP_FOLDER,unique_filename,), actions=['emotion'])
    print(objs)
        

@app.route("/questionnaire", methods=["GET", "POST"])
def handle_questionnaire():
    questions = load_questions_from_files(QUESTIONNAIRES)
    if request.method == "GET":
        selected_questions = choose_random_questions(questions, NUM_QUESTIONS)
        return jsonify(selected_questions)
    
    elif request.method == "POST":
        answers = request.get_json()
        results =  evaluate_answers(questions, answers)
        return {
            'result' : results.count(False)/len(results)
        }

@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Not found"}), 404

@app.errorhandler(405)
def method_not_allowed(error):
    return jsonify({"error": "Method Not Allowed"}), 405
