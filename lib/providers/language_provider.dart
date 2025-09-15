import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('en')); // Default to English

  void changeLanguage(String languageCode) {
    state = Locale(languageCode);
  }

  void changeToEnglish() => changeLanguage('en');
  void changeToKorean() => changeLanguage('ko');
  void changeToFrench() => changeLanguage('fr');
  void changeToGerman() => changeLanguage('de');
  void changeToJapanese() => changeLanguage('ja');
  void changeToVietnamese() => changeLanguage('vi');
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

// Helper class for language information
class LanguageInfo {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageInfo({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

// Available languages list
const List<LanguageInfo> availableLanguages = [
  LanguageInfo(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flag: '🇺🇸',
  ),
  LanguageInfo(
    code: 'ko',
    name: 'Korean',
    nativeName: '한국어',
    flag: '🇰🇷',
  ),
  LanguageInfo(
    code: 'fr',
    name: 'French',
    nativeName: 'Français',
    flag: '🇫🇷',
  ),
  LanguageInfo(
    code: 'de',
    name: 'German',
    nativeName: 'Deutsch',
    flag: '🇩🇪',
  ),
  LanguageInfo(
    code: 'ja',
    name: 'Japanese',
    nativeName: '日本語',
    flag: '🇯🇵',
  ),
  LanguageInfo(
    code: 'vi',
    name: 'Vietnamese',
    nativeName: 'Tiếng Việt',
    flag: '🇻🇳',
  ),
];
