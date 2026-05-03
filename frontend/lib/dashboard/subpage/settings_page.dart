import 'package:flutter/material.dart';
import '../../theme_provider.dart';
import 'change_password_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool location = true;

  Widget settingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple.withOpacity(0.1),
        child: Icon(icon, color: Colors.deepPurple),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text("Settings")),
          body: ListView(
            children: [
              /// PREFERENCES
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("PREFERENCES", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                ),
                child: Column(
                  children: [
                    settingTile(
                      icon: Icons.notifications,
                      title: "Notifications",
                      subtitle: "Receive alerts",
                      trailing: Switch(
                        value: notifications,
                        onChanged: (v) => setState(() => notifications = v),
                      ),
                    ),
                    settingTile(
                      icon: Icons.location_on,
                      title: "Location Access",
                      subtitle: "Allow access",
                      trailing: Switch(
                        value: location,
                        onChanged: (v) => setState(() => location = v),
                      ),
                    ),
                    settingTile(
                      icon: Icons.dark_mode,
                      title: "Dark Mode",
                      subtitle: "Switch theme",
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (v) => themeProvider.toggleTheme(v),
                      ),
                    ),
                    settingTile(
                      icon: Icons.language,
                      title: "Language",
                      subtitle: "English",
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),

              /// SECURITY
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("SECURITY", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                ),
                child: Column(
                  children: [
                    settingTile(
                      icon: Icons.lock,
                      title: "Change Password",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    settingTile(
                      icon: Icons.privacy_tip,
                      title: "Privacy Policy",
                      onTap: () {
                        // Navigate to Privacy Policy or show dialog
                      },
                    ),
                  ],
                ),
              ),

              /// SUPPORT
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("SUPPORT", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                ),
                child: settingTile(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {
                    // Navigate to Help & Support
                  },
                ),
              ),

              const SizedBox(height: 30),
              const Center(child: Text("Version 1.0.0", style: TextStyle(color: Colors.grey))),
              const SizedBox(height: 30),
            ],
          ),
        );
      }
    );
  }
}
