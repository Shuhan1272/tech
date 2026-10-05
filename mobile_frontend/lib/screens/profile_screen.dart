import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/app_theme.dart';
import '../core/snackbar_helper.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'address_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, AppTheme.primaryDark],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Text(
                    // Fixed: the old code did
                    // user['first_name']?.substring(0, 1), which
                    // throws a RangeError if first_name is an empty
                    // string (?? only guards null, not ''). This now
                    // falls back through first name -> email -> 'U'.
                    auth.initial,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  auth.displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  user['email'] ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Every one of these rows used to have an empty onTap — the
          // whole menu was decorative. The first three now open real
          // screens; the rest say plainly that they're not built yet
          // rather than silently doing nothing.
          _MenuSection(
            children: [
              _MenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
              ),
              _MenuItem(
                icon: Icons.location_on_outlined,
                title: 'Shipping Address',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen())),
              ),
              _MenuItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MenuSection(
            children: [
              _MenuItem(
                icon: Icons.receipt_long_outlined,
                title: 'Order History',
                onTap: () => AppSnackbar.showInfo(context, 'Order history is coming soon'),
              ),
              _MenuItem(
                icon: Icons.favorite_border,
                title: 'Wishlist',
                onTap: () => AppSnackbar.showInfo(context, 'Wishlist is coming soon'),
              ),
              _MenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () => AppSnackbar.showInfo(context, 'Support is coming soon'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout, size: 20),
            label: const Text('Log out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.danger,
              side: const BorderSide(color: AppTheme.danger, width: 1.2),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    // Added a confirmation step: logging out used to be a single
    // unguarded tap on an icon in the AppBar, easy to hit by accident.
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to continue shopping.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<Widget> children;
  const _MenuSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}
