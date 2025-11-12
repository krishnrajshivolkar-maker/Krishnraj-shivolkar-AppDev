from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # ✅ allows Flutter app to access this API

# Sample database (you can later replace this with real DB)
exercises = []

@app.route('/exercises', methods=['GET'])
def get_exercises():
    return jsonify(exercises)

@app.route('/add_exercise', methods=['POST'])
def add_exercise():
    data = request.json
    exercise_name = data.get('exercise')
    sets = data.get('sets')
    if not exercise_name or not sets:
        return jsonify({'error': 'Missing data'}), 400
    exercise = {"exercise": exercise_name, "sets": sets}
    exercises.append(exercise)
    return jsonify({'message': 'Exercise added successfully', 'data': exercise}), 201

if __name__ == '__main__':
    app.run(debug=True)
