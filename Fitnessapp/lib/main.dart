import 'package:flutter/material.dart';

void main() {
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness Tracker',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.redAccent,
        colorScheme: ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.white,
        ),
      ),
      home: FitnessHome(),
    );
  }
}

class FitnessHome extends StatefulWidget {
  @override
  _FitnessHomeState createState() => _FitnessHomeState();
}

class _FitnessHomeState extends State<FitnessHome> {
  int _selectedIndex = 0;

  // Shared data between pages
  List<Map<String, dynamic>> exercises = [];
  String userName = '';
  int progressCount = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      WorkoutPage(
        exercises: exercises,
        onExerciseAdded: (e) {
          setState(() {
            exercises.add(e);
            progressCount = exercises.length;
          });
        },
        onExerciseDeleted: (index) {
          setState(() {
            exercises.removeAt(index);
            progressCount = exercises.length;
          });
        },
      ),
      BMICalculatorPage(),
      ProfilePage(
        userName: userName,
        progressCount: progressCount,
        onProfileUpdated: (name) {
          setState(() {
            userName = name;
          });
        },
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: 'Workout'),
          BottomNavigationBarItem(
              icon: Icon(Icons.monitor_weight), label: 'BMI'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ---------------- WORKOUT PAGE ----------------

class WorkoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  final Function(Map<String, dynamic>) onExerciseAdded;
  final Function(int) onExerciseDeleted;

  const WorkoutPage({
    required this.exercises,
    required this.onExerciseAdded,
    required this.onExerciseDeleted,
  });

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  void _addExercise() {
    String name = '';
    int sets = 1;
    String day = 'Monday';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title:
              const Text('Add Exercise', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Exercise Name',
                    labelStyle: TextStyle(color: Colors.white)),
                onChanged: (value) => name = value,
              ),
              TextField(
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Sets',
                    labelStyle: TextStyle(color: Colors.white)),
                onChanged: (value) => sets = int.tryParse(value) ?? 1,
              ),
              DropdownButton<String>(
                value: day,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                onChanged: (String? newDay) => setState(() => day = newDay!),
                items: [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday'
                ]
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child:
                  const Text('Add', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                if (name.isNotEmpty) {
                  widget.onExerciseAdded(
                      {'name': name, 'sets': sets, 'day': day});
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteExercise(int index) {
    widget.onExerciseDeleted(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏋️ Workout Tracker'),
        backgroundColor: Colors.redAccent,
      ),
      body: widget.exercises.isEmpty
          ? const Center(
              child: Text('No exercises added yet.',
                  style: TextStyle(color: Colors.white, fontSize: 16)))
          : ListView.builder(
              itemCount: widget.exercises.length,
              itemBuilder: (context, index) {
                final e = widget.exercises[index];
                return Card(
                  color: Colors.grey[850],
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    title: Text(e['name'],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18)),
                    subtitle: Text('Sets: ${e['sets']} | Day: ${e['day']}',
                        style: const TextStyle(color: Colors.white70)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteExercise(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------- BMI CALCULATOR PAGE ----------------

class BMICalculatorPage extends StatefulWidget {
  @override
  _BMICalculatorPageState createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double? _bmiResult;
  String _bmiStatus = '';

  void _calculateBMI() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0) {
      final bmi = weight / ((height / 100) * (height / 100));
      setState(() {
        _bmiResult = bmi;
        if (bmi < 18.5) {
          _bmiStatus = 'Underweight';
        } else if (bmi < 24.9) {
          _bmiStatus = 'Normal';
        } else if (bmi < 29.9) {
          _bmiStatus = 'Overweight';
        } else {
          _bmiStatus = 'Obese';
        }
      });
    }
  }

  void _showBMIDisclaimer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
            const Text("What is BMI?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "BMI (Body Mass Index) is a measure of body fat based on height and weight. "
          "It helps indicate if you're underweight, normal, overweight, or obese. "
          "However, BMI doesn’t account for muscle mass or fitness level.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close',
                  style: TextStyle(color: Colors.redAccent)))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚖️ BMI Calculator'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
              onPressed: _showBMIDisclaimer,
              icon: const Icon(Icons.info_outline, color: Colors.white))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  labelStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  labelStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateBMI,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Calculate BMI'),
            ),
            const SizedBox(height: 20),
            if (_bmiResult != null)
              Text(
                'Your BMI: ${_bmiResult!.toStringAsFixed(1)} ($_bmiStatus)',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------- PROFILE PAGE ----------------

class ProfilePage extends StatefulWidget {
  final String userName;
  final int progressCount;
  final Function(String) onProfileUpdated;

  const ProfilePage({
    required this.userName,
    required this.progressCount,
    required this.onProfileUpdated,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _name;
  int? _age;
  String? _goal;

  void _editProfile() {
    final nameController = TextEditingController(text: _name ?? '');
    final ageController = TextEditingController(text: _age?.toString() ?? '');
    final goalController = TextEditingController(text: _goal ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title:
              const Text("Edit Profile", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: "Name",
                    labelStyle: TextStyle(color: Colors.white)),
              ),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: "Age",
                    labelStyle: TextStyle(color: Colors.white)),
              ),
              TextField(
                controller: goalController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: "Goal (e.g. Lose weight, Build muscle)",
                    labelStyle: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.redAccent))),
            TextButton(
                onPressed: () {
                  setState(() {
                    _name = nameController.text;
                    _age = int.tryParse(ageController.text);
                    _goal = goalController.text;
                  });
                  widget.onProfileUpdated(_name ?? '');
                  Navigator.pop(context);
                },
                child: const Text('Save',
                    style: TextStyle(color: Colors.redAccent))),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Profile'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit, color: Colors.white))
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _name == null ? "No profile created yet" : "Name: $_name",
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              if (_age != null)
                Text("Age: $_age",
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 18)),
              if (_goal != null)
                Text("Goal: $_goal",
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 18)),
              const SizedBox(height: 20),
              Text("Total Exercises Added: ${widget.progressCount}",
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 18)),
              const SizedBox(height: 30),
              const Text(
                "Stay consistent and disciplined 💪",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
