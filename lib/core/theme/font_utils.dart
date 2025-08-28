import 'package:flutter/material.dart';
import 'app_theme.dart';

class FontUtils {
  // Text styles for anime character names (Japanese)
  static TextStyle animeCharacterName(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontFamily: AppTheme.japaneseFont,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
  }

  // Text styles for anime titles (Japanese)
  static TextStyle animeTitle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      fontFamily: AppTheme.japaneseFont,
      fontWeight: FontWeight.w500,
    );
  }

  // Text styles for special Japanese text (using stylish RiiTN font)
  static TextStyle japaneseSpecial(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontFamily: AppTheme.specialFont, // Now uses RiiTN font
      fontWeight: FontWeight.w400,
      letterSpacing: 1.0, // More spacing for stylish effect
    );
  }

  // New: Stylish anime titles using RiiTN font
  static TextStyle stylishAnimeTitle(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      fontFamily: AppTheme.specialFont, // RiiTN font
      fontWeight: FontWeight.w400,
      letterSpacing: 2.0,
      height: 1.2,
    );
  }

  // New: Stylish character names using RiiTN font
  static TextStyle stylishCharacterName(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      fontFamily: AppTheme.specialFont, // RiiTN font
      fontWeight: FontWeight.w400,
      letterSpacing: 1.5,
    );
  }

  // New: Decorative Japanese text using RiiTN font
  static TextStyle decorativeJapanese(BuildContext context) {
    return Theme.of(context).textTheme.displayMedium!.copyWith(
      fontFamily: AppTheme.specialFont, // RiiTN font
      fontWeight: FontWeight.w400,
      letterSpacing: 3.0,
      height: 1.1,
    );
  }

  // Text styles for UI elements
  static TextStyle uiPrimary(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontFamily: AppTheme.primaryFont,
      fontWeight: FontWeight.w500,
    );
  }

  // Text styles for buttons
  static TextStyle buttonText(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
      fontFamily: AppTheme.primaryFont,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
  }

  // Text styles for anime descriptions
  static TextStyle animeDescription(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontFamily: AppTheme.japaneseFont,
      height: 1.5,
      letterSpacing: 0.25,
    );
  }

  // Text styles for character stats
  static TextStyle characterStats(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      fontFamily: AppTheme.primaryFont,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.25,
    );
  }

  // Helper to get font fallback for Japanese text
  static List<String> get japaneseFontFallback => [
    AppTheme.japaneseFont,
    AppTheme.specialFont,
    'Hiragino Sans',
    'Yu Gothic',
    'Meiryo',
    'MS Gothic',
    'sans-serif',
  ];

  // Helper to get primary font fallback
  static List<String> get primaryFontFallback => [
    AppTheme.primaryFont,
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];
}
