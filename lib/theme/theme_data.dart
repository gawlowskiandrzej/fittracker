import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart'; // zakładam że masz ten plik z paletą

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.background, // tło dla Scaffoldów
  
  primaryColor: AppColors.primary,

  textTheme: GoogleFonts.abelTextTheme().apply(
    bodyColor: AppColors.text,
    displayColor: AppColors.text,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.text,
    iconTheme: IconThemeData(color: AppColors.text),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppColors.text),
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
  iconTheme: IconThemeData(color: AppColors.text),
  listTileTheme: ListTileThemeData(
    titleTextStyle: TextStyle(
      color: AppColors.secondary,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    iconColor: AppColors.text,
    subtitleTextStyle: TextStyle(color: AppColors.text, fontSize: 12),
  ),
);
