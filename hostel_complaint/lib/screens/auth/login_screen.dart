import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../core/sky_widgets.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  void _submit() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
       return;
    }

    try {
      if (_isLogin) {
        await authProvider.login(email, password);
      } else {
        // Sign-up logic placeholder
        // await authProvider.signUp(email, password, ...);
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign up not fully implemented yet')));
         return;
      }

      if (mounted) {
         // Determine navigation based on role
         final role = authProvider.currentUser?.role;
         if (role != null) {
            if (role.name == 'student') {
               Navigator.pushReplacementNamed(context, '/student-dashboard');
            } else if (role.name == 'warden') {
               Navigator.pushReplacementNamed(context, '/warden-panel');
            } else {
               Navigator.pushReplacementNamed(context, '/admin-dashboard');
            }
         }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppTheme.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SkyBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_circle_rounded, size: 80, color: AppTheme.primaryBlue).animate().scale(),
                const SizedBox(height: 24),
                Text(
                  'Hostel Services',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ).animate().fadeIn(delay: 200.ms),
                Text(
                  'Your comfort our priority',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 48),

                GlassCard(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(_isLogin ? 'Login' : 'Sign Up'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    // setState(() => _isLogin = !_isLogin); 
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo: Please use existing credentials')));
                  },
                  child: Text(
                    _isLogin ? 'Don\'t have an account? Sign Up' : 'Already have an account? Login',
                    style: TextStyle(color: AppTheme.primaryBlue.withValues(alpha: 0.8), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.5),
      ),
    );
  }
}
