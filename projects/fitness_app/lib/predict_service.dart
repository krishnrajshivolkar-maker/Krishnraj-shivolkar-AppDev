import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictService {
  static const String baseUrl = "http://127.0.0.1:5000";

  static Future<double?> predictConsistency({
    required double dietScore,
    required double exerciseIntensity,
    required double workoutHours,
    required double sleepHours,
    required double previousStreakDays,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "diet_score": dietScore,
          "exercise_intensity": exerciseIntensity,
          "workout_hours": workoutHours,
          "sleep_hours": sleepHours,
          "previous_streak_days": previousStreakDays,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["predicted_consistency"];
      } else {
        print("Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
