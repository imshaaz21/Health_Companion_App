import json
import random

def load_questions_from_files(file_paths):
    questions = []
    for file_path in file_paths:
        with open(file_path, 'r') as file:
            data = json.load(file)
            questions.extend(data['questions'])
    return questions

def choose_random_questions(questions, total_questions):
    random.shuffle(questions)
    selected_questions = []
    remaining_questions = total_questions
    prev_tag = None  # To keep track of the previous tag
    while remaining_questions > 0:
        random.shuffle(questions)
        for question in questions:
            # Check if the question's tag is different from the previous one
            if prev_tag != question['tag']:
                if remaining_questions == 0:
                    break
                selected_questions.append(question)
                remaining_questions -= 1
                prev_tag = question['tag']
    return selected_questions

def evaluate_answers(questions, answers):
    results = []
    print(f"Answers {answers}")
    for question_id in answers:
        print(f"Question ID : {question_id} {type(question_id)}")
        response = answers[question_id]
        question_found = False
        for question in questions:
            if question['id'] == question_id:
                question_found = True
                if 'options' in question:
                    options = question['options']
                    if response in options and options[response]:
                        results.append(True)
                    else:
                        results.append(False)

        if not question_found:
            results.append(False)  # If the question ID is not found, consider the answer incorrect

    return results