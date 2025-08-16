import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/api_service.dart'; 

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  final ApiService _apiService = ApiService();
  String _selectedLang = 'en';
  bool _loading = true;

  final List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'id', 'name': 'Bahasa Indonesia', 'flag': '🇮🇩'},
    {'code': 'zh', 'name': 'Chinese', 'flag': '🇨🇳'},
    {'code': 'ms', 'name': 'Malay', 'flag': '🇲🇾'},
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final code = await _apiService.getLanguage();
      if (mounted) {
        setState(() {
          _selectedLang = code;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading language: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectLanguage(String code) async {
    try {
      await _apiService.setLanguage(code);
      if (!mounted) return;
      setState(() {
        _selectedLang = code;
      });
      context.setLocale(Locale(code));
      Navigator.pop(context);
    } catch (e) {
      print('Error setting language: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings_language_title').tr()),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: languages.map((lang) {
                final isSelected = lang['code'] == _selectedLang;
                return ListTile(
                  leading: Text(lang['flag']!, style: const TextStyle(fontSize: 22)),
                  title: Text(lang['name']!),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.amber) : null,
                  onTap: () => _selectLanguage(lang['code']!),
                );
              }).toList(),
            ),
    );
  }
}
