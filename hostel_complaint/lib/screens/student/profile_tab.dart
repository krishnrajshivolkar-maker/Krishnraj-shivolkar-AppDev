import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/sky_widgets.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const Center(child: Text('Not logged in'));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.lightBlue,
                child: Text(
                   user.name[0], 
                   style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)
                ),
              ),
              const SizedBox(height: 16),
              Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(user.email, style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 32),

              GlassCard(
                child: Column(
                  children: [
                    _ProfileItem(icon: Icons.person_outline, label: 'Edit Profile'),
                    const Divider(),
                    _ProfileItem(icon: Icons.settings_outlined, label: 'Settings'),
                    const Divider(),
                    _ProfileItem(icon: Icons.help_outline, label: 'Help & Support'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  authProvider.logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfileItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: () {},
    );
  }
}
