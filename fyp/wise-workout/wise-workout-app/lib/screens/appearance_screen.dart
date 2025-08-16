import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../themes/theme_notifier.dart';

class AppearanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final currentMode = themeNotifier.appThemeMode;
    final theme = Theme.of(context);
    Color _labelColor() => theme.colorScheme.onBackground.withOpacity(0.78);
    Color _descColor() => theme.textTheme.bodySmall?.color?.withOpacity(0.78) ?? _labelColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'appearance_title'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onBackground),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.background,
        foregroundColor: theme.colorScheme.onBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "appearance_theme_label".tr(),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "appearance_theme_description".tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _descColor(),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
              color: theme.colorScheme.surface,
              child: Column(
                children: [
                  RadioListTile<AppThemeMode>(
                    value: AppThemeMode.normal,
                    groupValue: currentMode,
                    onChanged: (mode) => themeNotifier.setThemeMode(mode!),
                    title: Text(
                      "appearance_theme_normal".tr(),
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    secondary: Icon(Icons.style, color: theme.colorScheme.primary),
                  ),
                  RadioListTile<AppThemeMode>(
                    value: AppThemeMode.dark,
                    groupValue: currentMode,
                    onChanged: (mode) => themeNotifier.setThemeMode(mode!),
                    title: Text(
                      "appearance_theme_dark".tr(),
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    secondary: Icon(Icons.dark_mode, color: theme.colorScheme.primary),
                  ),
                  RadioListTile<AppThemeMode>(
                    value: AppThemeMode.christmas,
                    groupValue: currentMode,
                    onChanged: (mode) => themeNotifier.setThemeMode(mode!),
                    title: Text(
                      "appearance_theme_christmas".tr(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFB71C1C),
                      ),
                    ),
                    secondary: const Icon(Icons.celebration, color: Color(0xFF388E3C)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Icon(
                currentMode == AppThemeMode.dark
                    ? Icons.dark_mode
                    : currentMode == AppThemeMode.normal
                    ? Icons.style
                    : currentMode == AppThemeMode.christmas
                    ? Icons.celebration
                    : Icons.brightness_auto,
                size: 64,
                color: currentMode == AppThemeMode.christmas
                    ? const Color(0xFFB71C1C)
                    : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
