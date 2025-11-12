import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

void main() {
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FitnessHome(),
    );
  }
}

class FitnessHome extends StatefulWidget {
  @override
  _FitnessHomeState createState() => _FitnessHomeState();
}

class _FitnessHomeState extends State<FitnessHome> {
  List<Map<String, dynamic>> exercises = [
    {'name': 'Push Ups', 'targetSets': 3, 'completedSets': 0},
    {'name': 'Squats', 'targetSets': 4, 'completedSets': 0},
  ];

  late Timer _timer;
  int _seconds = 0;
  bool _isRunning = false;

  // Timer controls
  void _startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    if (_isRunning) {
      _isRunning = false;
      _timer.cancel();
    }
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _seconds = 0;
    });
  }

  // Add new exercise with target sets
  void _addExercise() {
    TextEditingController nameController = TextEditingController();
    TextEditingController setsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: 'Enter exercise name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: setsController,
              decoration: InputDecoration(hintText: 'Enter target sets'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              String name = nameController.text.trim();
              int target = int.tryParse(setsController.text) ?? 0;
              if (name.isNotEmpty && target > 0) {
                setState(() {
                  exercises.add({
                    'name': name,
                    'targetSets': target,
                    'completedSets': 0,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _incrementSet(int index) {
    setState(() {
      if (exercises[index]['completedSets'] < exercises[index]['targetSets']) {
        exercises[index]['completedSets']++;
      }
    });
  }

  void _decrementSet(int index) {
    setState(() {
      if (exercises[index]['completedSets'] > 0) {
        exercises[index]['completedSets']--;
      }
    });
  }

  void _deleteExercise(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Exercise'),
        content: Text('Are you sure you want to delete "${exercises[index]['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                exercises.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  bool _isExerciseCompleted(int index) {
    return exercises[index]['completedSets'] >= exercises[index]['targetSets'];
  }

  @override
  void dispose() {
    if (_isRunning) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Fitness Tracker',
            style: GoogleFonts.pacifico(
              fontSize: 26,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.fitness_center), text: "Tracker"),
              Tab(icon: Icon(Icons.calendar_month), text: "Schedule"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTrackerView(),
            WeeklySchedulePage(exercises: exercises),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addExercise,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTrackerView() {
    return Column(
      children: [
        SizedBox(height: 20),
        CircleAvatar(radius: 60, backgroundImage: AssetImage('assets/images/logo.png')),
        SizedBox(height: 20),
        Text(
          'Timer: ${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _startTimer,
              icon: Icon(Icons.play_arrow),
              label: Text('Start'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _stopTimer,
              icon: Icon(Icons.pause),
              label: Text('Stop'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _resetTimer,
              icon: Icon(Icons.refresh),
              label: Text('Reset'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
        SizedBox(height: 20),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('My Exercises', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        Text('Note: 1 Set = 15 Reps', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              final completed = _isExerciseCompleted(index);
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: completed ? Colors.green[50] : Colors.white,
                child: ListTile(
                  leading: Icon(
                    completed ? Icons.check_circle : Icons.fitness_center,
                    color: completed ? Colors.green : Colors.blue,
                    size: 32,
                  ),
                  title: Text(
                    exercise['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    'Progress: ${exercise['completedSets']} / ${exercise['targetSets']} sets',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => _decrementSet(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, color: Colors.green),
                        onPressed: () => _incrementSet(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.grey[800]),
                        onPressed: () => _deleteExercise(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// 🌟 Weekly Schedule Page
class WeeklySchedulePage extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  WeeklySchedulePage({required this.exercises});

  @override
  _WeeklySchedulePageState createState() => _WeeklySchedulePageState();
}

class _WeeklySchedulePageState extends State<WeeklySchedulePage> {
  Map<String, List<String>> schedule = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  void _assignExercise(String day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Exercise to $day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.exercises.map((exercise) {
            return ListTile(
              title: Text(exercise['name']),
              trailing: ElevatedButton(
                onPressed: () {
                  setState(() {
                    schedule[day]!.add(exercise['name']);
                  });
                  Navigator.pop(context);
                },
                child: Text('Add'),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _removeExercise(String day, String exercise) {
    setState(() {
      schedule[day]!.remove(exercise);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: schedule.keys.map((day) {
        final exercises = schedule[day]!;
        return Card(
          margin: EdgeInsets.all(8),
          elevation: 3,
          child: ExpansionTile(
            title: Text(
              day,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            children: [
              ...exercises.map((e) => ListTile(
                    title: Text(e),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeExercise(day, e),
                    ),
                  )),
              TextButton.icon(
                onPressed: () => _assignExercise(day),
                icon: Icon(Icons.add),
                label: Text('Add Exercise'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
