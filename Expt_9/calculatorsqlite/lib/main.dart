// Import all the packages we need
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p; // Use prefix 'p' to fix the error

void main() {
  // Ensure Flutter is ready before we run the app
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// --- Database Helper Class (FOR EXP 9) ---
// This class will manage all our SQL commands
class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'calculations';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // Use the 'p.' prefix here to fix the error
    String path = p.join(await getDatabasesPath(), 'calculator.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Step 3: Create Table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expression TEXT NOT NULL,
        result TEXT NOT NULL
      )
    ''');
  }

  // Step 4: Insert Data
  Future<int> insertCalculation(String expression, String result) async {
    Database db = await database;
    return await db.insert(tableName, {'expression': expression, 'result': result});
  }

  // Step 5: Retrieve Data
  Future<List<Map<String, dynamic>>> getHistory() async {
    Database db = await database;
    return await db.query(tableName, orderBy: 'id DESC', limit: 20);
  }
}

// --- Main App UI ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Use light theme
      theme: ThemeData(
        primarySwatch: Colors.blue, // Sets the AppBar to blue
        scaffoldBackgroundColor: Colors.white, // Sets background to white
      ),
      home: const CalculatorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// This is the main screen of our app
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _output = "0";
  String _currentInput = "";
  double _num1 = 0;
  String _operator = "";
  String _fullExpression = "";

  void _buttonPressed(String buttonText) {
    if (buttonText == "C") {
      _output = "0";
      _currentInput = "";
      _num1 = 0;
      _operator = "";
      _fullExpression = "";
    } else if (buttonText == "<-") { // Backspace logic
      if (_currentInput.isNotEmpty) {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
        _output = _currentInput.isEmpty ? "0" : _currentInput;
        _fullExpression = _fullExpression.substring(0, _fullExpression.length - 1);
      }
    } else if (buttonText == "+" || buttonText == "-" || buttonText == "/" || buttonText == "x") {
      if (_currentInput.isEmpty) return; 
      _num1 = double.parse(_output);
      _operator = buttonText;
      _fullExpression += " $_operator ";
      _currentInput = ""; 
    } else if (buttonText == ".") {
      if (!_currentInput.contains(".")) {
        _currentInput += ".";
        _fullExpression += ".";
      }
    } else if (buttonText == "=") {
      if (_operator.isEmpty || _currentInput.isEmpty) return; 

      double num2 = double.parse(_output);
      String result = "0";

      if (_operator == "+") {
        result = (_num1 + num2).toString();
      }
      if (_operator == "-") {
        result = (_num1 - num2).toString();
      }
      if (_operator == "x") {
        result = (_num1 * num2).toString();
      }
      if (_operator == "/") {
        if (num2 == 0) {
          result = "Error";
        } else {
          result = (_num1 / num2).toString();
        }
      }

      if (result != "Error") {
        // Save to database
        _dbHelper.insertCalculation(_fullExpression, result);
        _output = result;
        _currentInput = result; 
      } else {
        _output = "Error";
        _currentInput = "";
      }
      _operator = "";
      _fullExpression = ""; 
      
    } else {
      if (_currentInput == "0" || _currentInput == _output) {
        _currentInput = buttonText;
        _fullExpression = buttonText;
      } else {
        _currentInput += buttonText;
        _fullExpression += buttonText;
      }
      _output = _currentInput;
    }

    setState(() {
      // Clean up the output
      if (_output != "Error" && _output.contains(".")) {
         _output = double.parse(_output).toStringAsFixed(2);
         _output = _output.replaceAll(RegExp(r'\.00$'), '');
      }
    });
  }
  
  // This shows the SQLite History
  void _showHistory() async {
    List<Map<String, dynamic>> history = await _dbHelper.getHistory();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(history[index]['expression']),
                subtitle: Text("= ${history[index]['result']}"),
              );
            },
          ),
        );
      },
    );
  }
  
  // Custom Button Widget to match your Exp 4 style
  Widget _buildButton(
    String buttonText, {
    Color buttonColor = const Color(0xFFB0BEC5), // Light grey/blue
    Color textColor = Colors.black,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: const EdgeInsets.all(24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0)
            ),
          ),
          onPressed: () => buttonText == "H" ? _showHistory() : _buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: textColor
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the colors from your Exp 4 screenshot
    final Color operatorColor = Colors.orange[600]!;
    final Color equalsColor = Colors.green[600]!;
    final Color numColor = Colors.blueGrey[100]!;


    return Scaffold(
      appBar: AppBar(
        // Added your name to the title
        title: const Text("Vighnesh's Calculator (Exp 9)"),
      ),
      body: Column(
        children: [
          // Display Screen
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _fullExpression.isEmpty ? " " : _fullExpression,
                    style: const TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                  Text(
                    _output,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),

          // Buttons
          const Divider(),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(children: [
                  _buildButton("C", buttonColor: operatorColor, textColor: Colors.white),
                  _buildButton("H", buttonColor: operatorColor, textColor: Colors.white), // Replaced +/-
                  _buildButton("<-", buttonColor: operatorColor, textColor: Colors.white), // Replaced %
                  _buildButton("x", buttonColor: operatorColor, textColor: Colors.white),
                ]),
                Row(children: [
                  _buildButton("7", buttonColor: numColor),
                  _buildButton("8", buttonColor: numColor),
                  _buildButton("9", buttonColor: numColor),
                  _buildButton("/", buttonColor: operatorColor, textColor: Colors.white),
                ]),
                Row(children: [
                  _buildButton("4", buttonColor: numColor),
                  _buildButton("5", buttonColor: numColor),
                  _buildButton("6", buttonColor: numColor),
                  _buildButton("-", buttonColor: operatorColor, textColor: Colors.white),
                ]),
                Row(
                  children: [
                    Expanded(
                      flex: 3, // Takes 3/4 of the space
                      child: Column(
                        children: [
                          Row(children: [
                            _buildButton("1", buttonColor: numColor),
                            _buildButton("2", buttonColor: numColor),
                            _buildButton("3", buttonColor: numColor),
                          ]),
                          Row(children: [
                            Expanded(
                              flex: 2, // 0 button is 2x wide
                              child: _buildButton("0", buttonColor: numColor),
                            ),
                            _buildButton(".", buttonColor: numColor),
                          ]),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1, // Takes 1/4 of the space
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: equalsColor,
                            padding: const EdgeInsets.symmetric(vertical: 64.0), // Make it tall
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)
                            ),
                          ),
                          onPressed: () => _buttonPressed("="),
                          child: const Text(
                            "=",
                            style: TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}