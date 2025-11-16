// ---------------- IMPORTS ----------------
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// ---------------- MAIN APP ----------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => FitnessProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

// ---------------- AUTH WRAPPER ----------------
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const HomeScreen(); // user logged in
        } else {
          return const AuthPage(); // login/register page
        }
      },
    );
  }
}

// ---------------- AUTH PAGE ----------------
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> authenticate(bool isLogin) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;
    if (!isLogin && password != confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } else {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set({'totalCalories': 0});
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Authentication error")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black, // Full black background
        child: Center(
          child: Container(
            width: size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular logo
                    CircleAvatar(
                      backgroundImage: AssetImage("assets/images/logo.png"),
                      radius: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Welcome",
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle:
                      GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: "Login"),
                    Tab(text: "Register"),
                  ],
                ),
                SizedBox(
                  height: 340,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLoginTab(),
                      _buildRegisterTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _customTextField("Email", emailController),
        const SizedBox(height: 12),
        _customTextField("Password", passwordController,
            obscureText: !showPassword, isPassword: true, toggle: () {
          setState(() => showPassword = !showPassword);
        }),
        const SizedBox(height: 20),
        _actionButton("Login", () => authenticate(true)),
        const SizedBox(height: 12),
        _googleButton(),
      ],
    );
  }

  Widget _buildRegisterTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _customTextField("Email", emailController),
        const SizedBox(height: 12),
        _customTextField("Password", passwordController,
            obscureText: !showPassword, isPassword: true, toggle: () {
          setState(() => showPassword = !showPassword);
        }),
        const SizedBox(height: 12),
        _customTextField("Confirm Password", confirmPasswordController,
            obscureText: !showConfirmPassword,
            isPassword: true, toggle: () {
          setState(() => showConfirmPassword = !showConfirmPassword);
        }),
        const SizedBox(height: 20),
        _actionButton("Register", () => authenticate(false)),
        const SizedBox(height: 12),
        _googleButton(),
      ],
    );
  }

  Widget _customTextField(String label, TextEditingController controller,
      {bool obscureText = false,
      bool isPassword = false,
      VoidCallback? toggle}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500, color: Colors.white70),
        filled: true,
        fillColor: Colors.grey.shade800,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: toggle,
              )
            : null,
      ),
    );
  }

  Widget _actionButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : Text(text,
                style:
                    GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _googleButton() {
    return GestureDetector(
      onTap: () {
        // Implement Google login
      },
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white70),
          color: Colors.black,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/google_logo.png",
                height: 24, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              "Sign in with Google",
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}


// ---------------- FITNESS PROVIDER ----------------
class FitnessProvider extends ChangeNotifier {
  int totalCalories = 0;
  bool stayLoggedIn = true; // new
  Map<String, List<String>> weeklySchedule = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': []
  };
  Map<String, Set<String>> completedExercises = {
    'Monday': {},
    'Tuesday': {},
    'Wednesday': {},
    'Thursday': {},
    'Friday': {},
    'Saturday': {},
    'Sunday': {}
  };
  final Map<String, int> exerciseCalories = {
    'Push-ups': 50,
    'Sit-ups': 40,
    'Squats': 60,
    'Jumping Jacks': 45,
    'Lunges': 55,
    'Plank': 35
  };

  // Chat messages for AI Coach
  List<ChatMessage> aiMessages = [
    ChatMessage(text: "Hi! What do you want today?", isUser: false)
  ];

  // -------------------- ADD EXERCISE --------------------
  void addExercise(String day, String exercise) {
    weeklySchedule[day]?.add(exercise);
    _saveExercises();
    notifyListeners();
  }

  void removeExercise(String day, String exercise) {
    weeklySchedule[day]?.remove(exercise);
    completedExercises[day]?.remove(exercise);
    _saveExercises();
    notifyListeners();
  }

  void completeExercise(String day, String exercise) {
    if (!(completedExercises[day]?.contains(exercise) ?? false)) {
      totalCalories += exerciseCalories[exercise] ?? 30;
      completedExercises[day]?.add(exercise);
      _saveCalories();
      notifyListeners();
    }
  }

  // -------------------- SAVE / LOAD CALORIES --------------------
  Future<void> _saveCalories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalCalories', totalCalories);

    // Save to Firestore
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'totalCalories': totalCalories}, SetOptions(merge: true));
    }
  }

  Future<void> loadCalories() async {
    final prefs = await SharedPreferences.getInstance();
    totalCalories = prefs.getInt('totalCalories') ?? 0;
    stayLoggedIn = prefs.getBool('stayLoggedIn') ?? true;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        totalCalories = doc.data()?['totalCalories'] ?? totalCalories;
        final exercisesData = doc.data()?['weeklySchedule'] as Map<String, dynamic>?;
        if (exercisesData != null) {
          weeklySchedule = exercisesData.map((k, v) => MapEntry(k, List<String>.from(v)));
        }
      }
    }
    notifyListeners();
  }

  Future<void> _saveExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'weeklySchedule': weeklySchedule}, SetOptions(merge: true));
    }
  }

  // -------------------- STAY LOGGED IN --------------------
  Future<void> setStayLoggedIn(bool value) async {
    stayLoggedIn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stayLoggedIn', stayLoggedIn);
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!stayLoggedIn) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

// -------------------- AI COACH --------------------
  void addAIMessage(ChatMessage msg) {
    aiMessages.add(msg);
    notifyListeners();
  }

  void clearAIMessages() {
    aiMessages = [ChatMessage(text: "Hi! What do you want today?", isUser: false)];
    notifyListeners();
  }
}

// ---------------- CHAT MESSAGE MODEL ----------------
class ChatMessage {
  final String text;
  final bool isUser; // true = user, false = AI
  ChatMessage({required this.text, required this.isUser});
}

// ---------------- HOME SCREEN ----------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> myTabs = const [
    Tab(text: 'Tracker'),
    Tab(text: 'Weekly Plan'),
    Tab(text: 'Profile'),
    Tab(text: 'AI Coach'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openPremium() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 36),
            const SizedBox(width: 8),
            Text(
              'Fitness Tracker',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _openPremium,
              child: CircleAvatar(
                radius: 20,
                backgroundImage:
                    const AssetImage('assets/images/premiumlogo.jpg'),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.redAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red,
          labelStyle:
              GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: myTabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TrackerScreen(),
          WeeklyPlanScreen(),
          ProfileScreen(),
          AICoachScreen(),
        ],
      ),
    );
  }
}

// ---------------- TRACKER SCREEN ----------------
class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});
  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  // --- NEW FIXED TIMER VARIABLES ---
  DateTime? startTime;
  Duration pausedDuration = Duration.zero;
  bool isRunning = false;
  late final Stream<Duration> ticker;

  @override
  void initState() {
    super.initState();

    // Ticks every second, calculates elapsed based on system clock
    ticker = Stream.periodic(const Duration(seconds: 1), (_) {
      if (!isRunning || startTime == null) return pausedDuration;
      return pausedDuration + DateTime.now().difference(startTime!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final today = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ][DateTime.now().weekday - 1];
    final todayExercises = provider.weeklySchedule[today] ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // --- TIMER DISPLAY ---
          StreamBuilder<Duration>(
            stream: ticker,
            builder: (context, snapshot) {
              final elapsed = snapshot.data ?? Duration.zero;

              final minutes =
                  elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
              final seconds =
                  elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

              return Text(
                "$minutes:$seconds",
                style: GoogleFonts.poppins(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // --- START / STOP / RESET ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // START
              ElevatedButton(
                onPressed: () {
                  if (!isRunning) {
                    startTime = DateTime.now();
                    isRunning = true;
                    setState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 12)),
                child: const Text('Start',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),

              // STOP
              ElevatedButton(
                onPressed: () {
                  if (isRunning) {
                    pausedDuration += DateTime.now().difference(startTime!);
                    isRunning = false;
                    setState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 12)),
                child: const Text('Stop',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),

              // RESET
              ElevatedButton(
                onPressed: () {
                  startTime = null;
                  pausedDuration = Duration.zero;
                  isRunning = false;
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 12)),
                child: const Text('Reset',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // --- TODAY'S EXERCISES ---
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Today's Exercises ($today)",
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: todayExercises.isEmpty
                        ? Center(
                            child: Text("No exercises scheduled today.",
                                style: GoogleFonts.poppins(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: todayExercises.length,
                            itemBuilder: (context, index) {
                              final exercise = todayExercises[index];
                              final isCompleted =
                                  provider.completedExercises[today]
                                          ?.contains(exercise) ??
                                      false;

                              return Card(
                                elevation: 3,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  title: Text(
                                    exercise,
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: isCompleted
                                          ? Colors.grey
                                          : Colors.black87,
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.check_circle,
                                        color: isCompleted
                                            ? Colors.grey
                                            : Colors.green),
                                    onPressed: () =>
                                        provider.completeExercise(today, exercise),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- WEEKLY PLAN SCREEN ----------------
// [Unchanged from your current main.dart]

class WeeklyPlanScreen extends StatelessWidget {
  const WeeklyPlanScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: StatefulBuilder(
                builder: (context, setState) {
                  bool hovered = false;
                  return MouseRegion(
                    onEnter: (_) => setState(() => hovered = true),
                    onExit: (_) => setState(() => hovered = false),
                    child: GestureDetector(
                      onTap: () => _showGlobalAddExerciseSheet(context, provider),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: hovered ? Colors.redAccent : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          "Add Exercise",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: hovered ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...provider.weeklySchedule.keys.map((day) {
            final exercises = provider.weeklySchedule[day] ?? [];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ExpansionTile(
                title: Text(day,
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                children: [
                  if (exercises.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("No exercises added.",
                          style: GoogleFonts.poppins(color: Colors.grey)),
                    ),
                  ...exercises.map((exercise) {
                    final completed =
                        provider.completedExercises[day]?.contains(exercise) ??
                            false;
                    return ListTile(
                      title: Text(exercise,
                          style: GoogleFonts.robotoMono(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            decoration: completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: completed ? Colors.grey : Colors.black87,
                          )),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => provider.removeExercise(day, exercise),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }).toList()
        ],
      ),
    );
  }

  void _showGlobalAddExerciseSheet(
      BuildContext context, FitnessProvider provider) {
    final TextEditingController manualController = TextEditingController();
    String selectedDay = 'Monday';
    String selectedExercise = '';
    bool manualMode = false;

    final exerciseList = [
      {'name': 'Push‑ups', 'target': 'Chest, Triceps'},
      {'name': 'Squats', 'target': 'Legs, Glutes'},
      {'name': 'Lunges', 'target': 'Legs, Core'},
      {'name': 'Plank', 'target': 'Core, Shoulders'},
      {'name': 'Jumping Jacks', 'target': 'Full Body'},
      {'name': 'Sit‑ups', 'target': 'Abs'},
    ];

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(16),
            height: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(labelText: 'Select Day'),
                  items: provider.weeklySchedule.keys.map((d) {
                    return DropdownMenuItem(value: d, child: Text(d));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedDay = v);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedExercise.isEmpty ? null : selectedExercise,
                        decoration:
                            const InputDecoration(labelText: 'Select Exercise'),
                        items: exerciseList.map((e) {
                          return DropdownMenuItem(
                            value: e['name'],
                            child: Text("${e['name']} — ${e['target']}"),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            manualMode = false;
                            selectedExercise = v ?? '';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      tooltip: 'Add custom exercise',
                      onPressed: () {
                        setState(() {
                          manualMode = true;
                          manualController.text = '';
                          selectedExercise = '';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (manualMode)
                  TextField(
                    controller: manualController,
                    decoration: const InputDecoration(
                      labelText: 'Enter custom exercise name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                const Spacer(),
                Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                      ),
                      onPressed: () {
                        final exercise =
                            manualMode ? manualController.text.trim() : selectedExercise;
                        if (exercise.isNotEmpty) {
                          provider.addExercise(selectedDay, exercise);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

// ---------------- PROFILE SCREEN ----------------
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FitnessProvider>(context, listen: false).loadCalories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
              radius: 60, backgroundImage: AssetImage('assets/images/icon.jpg')),
          const SizedBox(height: 20),
          Text(
            "My Profile",
            style:
                GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            "Total Calories Burned:",
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(
            "${provider.totalCalories} kcal",
            style: GoogleFonts.poppins(
                fontSize: 26, fontWeight: FontWeight.bold, color: Colors.redAccent),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Stay Logged In", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              Switch(
                value: provider.stayLoggedIn,
                onChanged: (val) => provider.setStayLoggedIn(val),
                activeColor: Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => provider.logout(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ---------------- AI COACH SCREEN ----------------
class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});
  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Future<void> fetchAIResponse(String choice) async {
    final provider = Provider.of<FitnessProvider>(context, listen: false);

    // Add user's message
    provider.addAIMessage(ChatMessage(text: choice, isUser: true));
    inputController.clear();
    _scrollToBottom();

    // Add typing animation message
    provider.addAIMessage(ChatMessage(text: "", isUser: false));
    _scrollToBottom();

    try {
      final apiKey = "AIzaSyAaZS9WssJHsdZPDy2AIBF-WwrsMJHbTPc";
      final url = Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "x-goog-api-key": apiKey,
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": choice}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data["candidates"] as List<dynamic>?;
        String result = "I couldn't fetch a response.";
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]["content"];
          result = (content["parts"] as List).map((p) => p["text"]).join();
        }

        // Animate AI message typing
        provider.aiMessages.removeLast();
        provider.addAIMessage(ChatMessage(text: "", isUser: false));
        await _typeText(result, provider);
      } else {
        provider.aiMessages.removeLast();
        provider.addAIMessage(
            ChatMessage(text: "Failed to fetch AI response.", isUser: false));
      }
    } catch (e) {
      provider.aiMessages.removeLast();
      provider.addAIMessage(ChatMessage(text: "Error: $e", isUser: false));
    }
  }

  Future<void> _typeText(String text, FitnessProvider provider) async {
    String displayed = "";
    for (var char in text.split('')) {
      displayed += char;
      provider.aiMessages.last =
          ChatMessage(text: displayed, isUser: false);
      provider.notifyListeners();
      await Future.delayed(const Duration(milliseconds: 15));
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white, // same as other tabs
      body: Column(
        children: [
          Expanded(
  child: ListView.builder(
    controller: scrollController,
    padding: const EdgeInsets.all(12),
    itemCount: provider.aiMessages.length,
    itemBuilder: (context, index) {
      final msg = provider.aiMessages[index];
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: msg.isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show coach logo only for AI messages
            if (!msg.isUser)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage("assets/images/coach_logo.png"),
                ),
              ),
            // Message bubble
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  msg.text,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    },
  ),
),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (event) {
                if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                  final text = inputController.text.trim();
                  if (text.isNotEmpty) fetchAIResponse(text);
                }
              },
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputController,
                      decoration: const InputDecoration(
                        hintText: "Ask AI Coach...",
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) fetchAIResponse(text);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.redAccent),
                    onPressed: () {
                      final text = inputController.text.trim();
                      if (text.isNotEmpty) fetchAIResponse(text);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- PREMIUM SCREEN ----------------

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});
  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  final List<String> images = [
    'assets/images/pre0.1.jpg',
    'assets/images/pre2.jpg',
    'assets/images/pre0.4.jpg',
    'assets/images/pre1.jpg',
    'assets/images/pre0.3.jpg',
    'assets/images/pre3.jpg',
  ];

  final List<Color> bgColors = [
    Color(0xFF000000),
    Color(0xFF544E4E),
    Color(0xFF000000),
    Color(0xFF111111),
    Color(0xFF000000),
    Color(0xFFFBFEF7),
  ];

  int currentIndex = 0;

  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String selectedBodyType = "Muscular";

  String exerciseResult = "";
  bool isLoading = false;

  bool showDropdown = false;
  OverlayEntry? societyOverlay;

  late AnimationController dropCtrl;
  late Animation<double> scaleAnim;
  late Animation<double> opacityAnim;
  late Animation<Offset> slideAnim;

  final List<String> bodyTypes = [
    'Lean', 'Muscular', 'Heavy', 'Ectomorph', 'Mesomorph',
    'Endomorph', 'Athletic', 'Slim', 'Stocky', 'Average',
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), changeSlide);

    dropCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    scaleAnim = CurvedAnimation(parent: dropCtrl, curve: Curves.elasticOut);
    opacityAnim = CurvedAnimation(parent: dropCtrl, curve: Curves.easeOut);
    slideAnim = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: dropCtrl, curve: Curves.easeOut));
  }

  void toggleDropdown() {
    if (showDropdown) {
      closeDropdown();
    } else {
      showDropdown = true;
      final overlay = Overlay.of(context);
      societyOverlay = OverlayEntry(
        builder: (context) => GestureDetector(
          onTap: closeDropdown,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Positioned(
                top: kToolbarHeight + 8,
                right: 16,
                child: Material(
                  color: Colors.transparent,
                  child: FadeTransition(
                    opacity: opacityAnim,
                    child: SlideTransition(
                      position: slideAnim,
                      child: ScaleTransition(
                        scale: scaleAnim,
                        child: Container(
                          width: 220,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildDropdownItem(
                                imagePath: "assets/images/community.jpg",
                                label: "Fit Society",
                                url:
                                    "https://chat.whatsapp.com/LtZFo643GxbFSWuW9HmXxZ?mode=wwt",
                              ),
                              const Divider(height: 16, thickness: 1),
                              _buildDropdownItem(
                                imagePath: "assets/images/personal.jpg",
                                label: "Personal Trainers",
                                url:
                                    "https://chat.whatsapp.com/FzMjI5xtVG55mYWTF2EC94?mode=wwt",
                              ),
                              const Divider(height: 16, thickness: 1),
                              _buildDropdownItem(
                                imagePath: "assets/images/products.jpg",
                                label: "Products",
                                url: null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      overlay?.insert(societyOverlay!);
      dropCtrl.forward();
    }
  }

  Widget _buildDropdownItem(
      {required String imagePath, required String label, String? url}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (url != null) {
            _launchURL(url);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Available Soon")));
          }
        },
        child: Row(
          children: [
            Image.asset(imagePath, width: 30, height: 30, fit: BoxFit.cover),
            const SizedBox(width: 10),
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void closeDropdown() {
    if (showDropdown) {
      showDropdown = false;
      dropCtrl.reverse();
      societyOverlay?.remove();
      societyOverlay = null;
    }
  }

  void changeSlide() {
    if (!mounted) return;
    setState(() {
      currentIndex = (currentIndex + 1) % images.length;
    });
    Future.delayed(const Duration(seconds: 3), changeSlide);
  }

  Future<void> fetchExercises() async {
  final int height = int.tryParse(heightController.text) ?? 0;
  final int weight = int.tryParse(weightController.text) ?? 0;
  final int age = int.tryParse(ageController.text) ?? 0;

  if (height == 0 || weight == 0 || age == 0) {
    setState(() => exerciseResult = "Please enter valid details.");
    return;
  }

  setState(() {
    isLoading = true;
    exerciseResult = "";
  });

  try {
    final apiKey = "AIzaSyAaZS9WssJHsdZPDy2AIBF-WwrsMJHbTPc";
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": apiKey,
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": "I am $age years old, $height cm tall, weigh $weight kg, and my body type is $selectedBodyType. " +
                  "Calculate my fitness score based on BMI and body type. " +
                  "Suggest a list of 5-8 exercises suitable for me, including number of reps/sets based on my fitness level. " +
                  "Mention which body part each exercise develops. " +
                  "Format the output as: Exercise Name — Reps/Sets — Target Body Part. " +
                  "Also suggest a slightly higher intensity version for progression next week."
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Gemini returns `candidates` array
      final candidates = data["candidates"] as List<dynamic>?;
      if (candidates != null && candidates.isNotEmpty) {
        final first = candidates[0];
        final content = first["content"];
        final parts = (content["parts"] as List).map((p) => p["text"]).join();
        setState(() => exerciseResult = parts);
      } else {
        setState(() => exerciseResult = "No suggestions returned.");
      }
    } else {
      setState(() => exerciseResult =
          "Failed to fetch exercises. Status: ${response.statusCode} — ${response.body}");
    }
  } catch (e) {
    setState(() => exerciseResult = "Error: $e");
  } finally {
    setState(() => isLoading = false);
  }
}


  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: closeDropdown,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          centerTitle: true,
          title: Text(
            'Premium',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.amberAccent,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: toggleDropdown,
                  child: Tooltip(
                    message: "Fit Society",
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/premium.png',
                        height: 36,
                        width: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: ClipRect(
                  key: ValueKey<String>(images[currentIndex]),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: bgColors[currentIndex],
                      child: Center(
                        child: Image.asset(
                          images[currentIndex],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Enter Your Details",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Height (cm)",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Weight (kg)",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Age",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedBodyType,
                        items: bodyTypes
                            .map((body) => DropdownMenuItem(
                                  value: body,
                                  child: Text(body),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() {
                            selectedBodyType = val;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              heightController.clear();
                              weightController.clear();
                              ageController.clear();
                              setState(() {
                                exerciseResult = "";
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            child: const Text("Clear",
                                style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: fetchExercises,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("Get Exercises",
                                    style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (exerciseResult.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(
                            maxHeight: 250,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              exerciseResult,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
