import 'package:flutter/material.dart';

void main() {
  runApp(SmartCalc());
}

class SmartCalc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCalc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: SmartCalcHome(),
    );
  }
}

class SmartCalcHome extends StatefulWidget {
  @override
  _SmartCalcHomeState createState() => _SmartCalcHomeState();
}

class _SmartCalcHomeState extends State<SmartCalcHome> {
  String _input = "";
  String _output = "0";

  final List<String> keys = [
    'AC', '⌫', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '0', '.', '='
  ];

  void _handlePress(String key) {
    setState(() {
      switch (key) {
        case 'AC':
          _input = "";
          _output = "0";
          break;
        case '⌫':
          if (_input.isNotEmpty) {
            _input = _input.substring(0, _input.length - 1);
          }
          break;
        case '=':
          _evaluate();
          break;
        default:
          _input += key;
      }
    });
  }

  void _evaluate() {
    try {
      String expression = _input
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('%', '/100');
      double result = _parseAndEval(expression);
      _output = result.toStringAsFixed(3).replaceAll(RegExp(r'\.0+$'), '');
    } catch (e) {
      _output = "Error";
    }
  }

  double _parseAndEval(String expr) {
    List<String> tokens = _tokenize(expr);
    return _compute(tokens);
  }

  List<String> _tokenize(String expr) {
    List<String> tokens = [];
    String current = '';
    for (int i = 0; i < expr.length; i++) {
      String c = expr[i];
      if ('0123456789.'.contains(c)) {
        current += c;
      } else {
        if (current.isNotEmpty) tokens.add(current);
        tokens.add(c);
        current = '';
      }
    }
    if (current.isNotEmpty) tokens.add(current);
    return tokens;
  }

  double _compute(List<String> tokens) {
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        double a = double.parse(tokens[i - 1]);
        double b = double.parse(tokens[i + 1]);
        double res = (tokens[i] == '*') ? a * b : a / b;
        tokens.replaceRange(i - 1, i + 2, [res.toString()]);
        i = 0;
      }
    }

    double result = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      String op = tokens[i];
      double val = double.parse(tokens[i + 1]);
      if (op == '+') result += val;
      if (op == '-') result -= val;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SmartCalc')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              alignment: Alignment.bottomRight,
              color: Colors.deepPurple.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(_input,
                      style: TextStyle(fontSize: 28, color: Colors.black54)),
                  SizedBox(height: 12),
                  Text(_output,
                      style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple)),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(8),
              child: GridView.builder(
                itemCount: keys.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return _buildKey(keys[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    Color color;
    if (key == 'AC' || key == '⌫') {
      color = Colors.redAccent;
    } else if (key == '=') {
      color = Colors.deepPurple;
    } else if ('÷×-+%'.contains(key)) {
      color = Colors.blueAccent;
    } else {
      color = Colors.grey.shade300;
    }

    return ElevatedButton(
      onPressed: () => _handlePress(key),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(
        key,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
