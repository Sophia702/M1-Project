import 'package:shared_preferences/shared_preferences.dart';

/// Minimal local persistence. For now only tracks whether first-run onboarding
/// has been completed; profile/settings/session persistence comes later.
class AppPrefs {
  AppPrefs._();
  static const _kOnboarded = 'onboarded';

  static Future<bool> isOnboarded() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kOnboarded) ?? false;
  }

  static Future<void> setOnboarded() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kOnboarded, true);
  }

  static const _kVoice = 'voiceEnabled';

  static Future<bool> voiceEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kVoice) ?? false;
  }

  static Future<void> setVoiceEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kVoice, value);
  }
}
