import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'translations/en_US.dart';
import 'translations/fa_IR.dart';

class LocalizationService extends Translations {
  // Default locale
  static const locale = Locale('en', 'US');

  // Fallback locale
  static const fallbackLocale = Locale('en', 'US');

  // Supported languages
  static final languages = ['English', 'فارسی'];

  // Supported locales
  static final locales = [const Locale('en', 'US'), const Locale('fa', 'IR')];

  // Keys and their translations
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'fa_IR': faIR,
  };

  // Gets locale from language, and updates the locale
  static void changeLocale(String lang) {
    final locale = _getLocaleFromLanguage(lang);
    Get.updateLocale(locale);
  }

  // Finds language in `languages` list and returns it as Locale
  static Locale _getLocaleFromLanguage(String lang) {
    for (int i = 0; i < languages.length; i++) {
      if (lang == languages[i]) return locales[i];
    }
    return Get.locale ?? locale;
  }

  static String getCurrentLanguage() {
    final locale = Get.locale;
    if (locale?.languageCode == 'fa') {
      return 'فارسی';
    }
    return 'English';
  }

  static bool isPersian() {
    return Get.locale?.languageCode == 'fa';
  }
}
