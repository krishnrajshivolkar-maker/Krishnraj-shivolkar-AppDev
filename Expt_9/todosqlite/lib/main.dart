// Import all the packages we need
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// --- Database Helper Class (Implements CRUD) ---
class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'tasks';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = p.join(await getDatabasesPath(), 'todo_list.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // CREATE: Step 3 - Create Table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        is_done INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // READ: Step 5 - Retrieve Data
  Future<List<Map<String, dynamic>>> getTasks() async {
    Database db = await database;
    return await db.query(tableName, orderBy: 'id DESC');
  }

  // CREATE: Step 4 - Insert Data
  Future<int> insertTask(String title) async {
    Database db = await database;
    return await db.insert(tableName, {'title': title, 'is_done': 0});
  }

  // DELETE: Step 6 - Delete Data
  Future<int> deleteTask(int id) async {
    Database db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// --- Main App UI ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vighnesh\'s SQLite To-Do',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Use a calming teal color
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const TodoListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// This is the main screen of our app
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshTasks(); // Load tasks from database when the app starts
  }

  void _refreshTasks() async {
    final data = await _dbHelper.getTasks();
    setState(() {
      _tasks = data;
    });
  }

  // Handles adding new task to DB and UI
  void _addTask() async {
    if (_textController.text.isNotEmpty) {
      await _dbHelper.insertTask(_textController.text);
      _textController.clear();
      _refreshTasks(); // Reload the list
    }
  }

  // Handles deleting task from DB and UI
  void _deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    _refreshTasks(); // Reload the list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- Input Form (CREATE operation) ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a new task...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton.small(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
          // --- Task List (READ and DELETE operations) ---
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Dismissible(
                  key: Key(task['id'].toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteTask(task['id']);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(task['title']),
                    subtitle: Text('ID: ${task['id']} (Swipe to Delete)'),
                    // A simple way to show the task is complete (UPDATE operation visualized)
                    leading: Icon(
                      task['is_done'] == 1 ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: task['is_done'] == 1 ? Colors.green : Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}