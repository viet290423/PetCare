import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petcare/presentation/provider/SettingsProvider.dart';
import 'package:petcare/presentation/ui/auth/AuthViewModel.dart';
import 'package:petcare/presentation/ui/auth/LoginScreen.dart';

import '../../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settings_title ?? 'Cài đặt'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          final currentTheme = settings.themeMode;
          final currentLocale = settings.locale;
          return ListView(
            children: [
              _SectionHeader(title: l10n?.section_theme ?? 'Giao diện'),
              RadioListTile<ThemeMode>(
                title: Text(l10n?.theme_system ?? 'Theo hệ thống'),
                value: ThemeMode.system,
                groupValue: currentTheme,
                onChanged: (v) => settings.setThemeMode(v ?? ThemeMode.system),
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n?.theme_light ?? 'Sáng'),
                value: ThemeMode.light,
                groupValue: currentTheme,
                onChanged: (v) => settings.setThemeMode(v ?? ThemeMode.system),
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n?.theme_dark ?? 'Tối'),
                value: ThemeMode.dark,
                groupValue: currentTheme,
                onChanged: (v) => settings.setThemeMode(v ?? ThemeMode.system),
              ),
              const Divider(),
              _SectionHeader(title: l10n?.section_language ?? 'Ngôn ngữ'),
              RadioListTile<String?>(
                title: Text(l10n?.language_system ?? 'Theo hệ thống'),
                value: null,
                groupValue: currentLocale?.languageCode,
                onChanged: (v) => settings.setLocale(null),
              ),
              RadioListTile<String?>(
                title: Text(l10n?.language_vi ?? 'Tiếng Việt'),
                value: 'vi',
                groupValue: currentLocale?.languageCode,
                onChanged: (v) => settings.setLocale(const Locale('vi')),
              ),
              RadioListTile<String?>(
                title: Text(l10n?.language_en ?? 'English'),
                value: 'en',
                groupValue: currentLocale?.languageCode,
                onChanged: (v) => settings.setLocale(const Locale('en')),
              ),
              const Divider(),
              _SectionHeader(title: l10n?.section_other ?? 'Khác'),
              SwitchListTile(
                title: Text(l10n?.notifications_toggle ?? 'Nhận thông báo'),
                value: true,
                onChanged: (v) {
                  // TODO: implement notification opt-in/out if needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n?.coming_soon ?? 'Tính năng sẽ sớm có')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n?.about ?? 'Giới thiệu'),
                subtitle: Text(l10n?.about_description ?? 'Giới thiệu'),
              ),
              const Divider(),
              _SectionHeader(title: l10n?.section_account ?? 'Tài khoản'),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  l10n?.logout ?? 'Đăng xuất',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  await context.read<AuthViewModel>().signOutUser();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}


