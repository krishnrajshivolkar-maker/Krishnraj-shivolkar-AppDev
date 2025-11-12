# train_model.py
import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
from joblib import dump

# Create a small synthetic dataset
# Features: diet_hours_per_day, exercise_hours_per_day, sleep_hours_per_day, age, gender (0/1), current_weight, target_weight
np.random.seed(42)
N = 200
diet = np.random.uniform(0, 3, N) # hours of focused dieting/meal-planning per day
exercise = np.random.uniform(0, 3, N) # hours exercise per day
sleep = np.random.uniform(4, 9, N)
age = np.random.randint(18, 60, N)
gender = np.random.randint(0,2,N)
current_weight = np.random.uniform(50, 110, N)
target_weight = current_weight - np.random.uniform(1, 20, N)

# A synthetic target: weeks_to_target (lower with more exercise/diet)
weeks = np.clip( 50 - (exercise * 8 + diet * 6 + (sleep-6)) - (current_weight - target_weight) * 0.7 + (age-30)*0.1 + gender*2 + np.random.normal(0,3,N), 2, 200)

df = pd.DataFrame({
'diet': diet,
'exercise': exercise,
'sleep': sleep,
'age': age,
'gender': gender,
'current_weight': current_weight,
'target_weight': target_weight,
'weeks': weeks
})

X = df[['diet','exercise','sleep','age','gender','current_weight','target_weight']]
y = df['weeks']

model = LinearRegression()
model.fit(X, y)

# Save model
dump(model, 'model.joblib')
print('Model trained and saved to model.joblib')
