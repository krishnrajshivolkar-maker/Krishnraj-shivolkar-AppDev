import 'dart:io';

void main() {
  // output
  print("Enter your name:");

  // input
  String? name = stdin.readLineSync(); 

  // display output
  print("Hello, $name! Welcome to Dart programming.");
}
