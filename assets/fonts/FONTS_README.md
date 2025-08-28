# Font Files Placeholder

This directory should contain the following font files:

## Inter Font Family (Primary UI Font)
- `Inter-Regular.ttf`
- `Inter-Medium.ttf` 
- `Inter-SemiBold.ttf`
- `Inter-Bold.ttf`

Download from: https://fonts.google.com/specimen/Inter

## Noto Sans Japanese (Anime/Japanese Text)
- `NotoSansJP-Regular.ttf`
- `NotoSansJP-Medium.ttf`
- `NotoSansJP-SemiBold.ttf` 
- `NotoSansJP-Bold.ttf`

Download from: https://fonts.google.com/noto/specimen/Noto+Sans+JP

## Custom Japanese Font (Optional)
- `JapaneseFont-Regular.ttf`

You can use any Japanese font you prefer for this.

## Installation Instructions:
1. Download the font files from the links above
2. Place them in this `assets/fonts/` directory
3. Make sure the filenames match exactly as specified in `pubspec.yaml`
4. Run `flutter clean && flutter pub get` after adding the fonts

## Usage:
The fonts are already configured in:
- `lib/core/theme/app_theme.dart` - Theme configuration
- `lib/core/theme/font_utils.dart` - Helper utilities for specific use cases

Use `FontUtils` class for anime-specific text styling:
- `FontUtils.animeCharacterName(context)` - For character names
- `FontUtils.animeTitle(context)` - For anime titles  
- `FontUtils.japaneseSpecial(context)` - For special Japanese text
- `FontUtils.buttonText(context)` - For button text
- `FontUtils.animeDescription(context)` - For descriptions
