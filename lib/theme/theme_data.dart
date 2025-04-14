import 'package:flutter/material.dart';
import 'colors.dart'; // zakładam że masz ten plik z paletą

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.background, // tło dla Scaffoldów
  primaryColor: AppColors.primary,

  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.text),
    bodyMedium: TextStyle(color: AppColors.text),
    titleLarge: TextStyle(color: AppColors.text),
    titleMedium: TextStyle(color: AppColors.text),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.secondary,
    foregroundColor: AppColors.text,
    iconTheme: IconThemeData(color: AppColors.text),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.background,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.text,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(color: AppColors.text),
    labelStyle: TextStyle(color: AppColors.text),
  ),
  iconTheme: IconThemeData(
    color: AppColors.text,
  ),
);
