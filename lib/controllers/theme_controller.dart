import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  static const _darkModeKey = 'dark_mode';
  final GetStorage? _storage;
  final isDarkMode = false.obs;

  ThemeController({bool useStorage = true})
    : _storage = useStorage ? GetStorage() : null;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storage?.read<bool>(_darkModeKey) ?? false;
  }

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme(bool enabled) async {
    isDarkMode.value = enabled;
    await _storage?.write(_darkModeKey, enabled);
  }
}
