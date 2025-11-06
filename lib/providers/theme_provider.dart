import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  void toggle() {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
  }

  void setMode(ThemeMode mode) => state = mode;
}

final themeModeProvider = StateNotifierProvider<ThemeController, ThemeMode>(
  (ref) => ThemeController(),
);


