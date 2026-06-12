/// Intents the voice agent understands. Keyword/phrase matching for the MVP —
/// a clean seam to swap in richer NLU (on-device or cloud) later.
enum VoiceIntent {
  startWalk,
  endWalk,
  imOkay,
  breathing,
  callEmergency,
  callSupport,
  goHome,
  goProgress,
  goProfile,
  goSettings,
  yes,
  no,
  help,
  disableVoice,
  unknown,
}

/// Pure, dependency-free mapping from recognised text to a [VoiceIntent].
/// Kept separate so it's unit-testable without any plugins.
class VoiceIntentParser {
  const VoiceIntentParser();

  bool _has(String t, List<String> keys) => keys.any(t.contains);

  VoiceIntent parse(String raw) {
    final t = raw.toLowerCase().trim();
    if (t.isEmpty) return VoiceIntent.unknown;
    // Word tokens, for short/ambiguous words (so "now" isn't read as "no").
    final words = t.split(RegExp(r'[^a-z]+')).where((w) => w.isNotEmpty).toSet();
    bool word(List<String> ks) => ks.any(words.contains);

    // Turn voice off — check before other "stop" words.
    if (_has(t, ['stop listening', 'turn off voice', 'disable voice',
        'voice off', 'exit voice'])) {
      return VoiceIntent.disableVoice;
    }

    // Confirmations (used during the call-confirm flow).
    if (word(['yes', 'yeah', 'yep', 'confirm', 'correct']) ||
        _has(t, ['go ahead'])) {
      return VoiceIntent.yes;
    }
    if (word(['no', 'nope', 'cancel']) || _has(t, ['never mind', 'nevermind'])) {
      return VoiceIntent.no;
    }

    // Interventions.
    if (_has(t, ['call emergency', 'emergency contact', 'call my contact',
        'call contact'])) {
      return VoiceIntent.callEmergency;
    }
    if (_has(t, ['support line', 'call support', 'helpline', 'help line'])) {
      return VoiceIntent.callSupport;
    }
    if (_has(t, ['breath', 'breathe', 'breathing'])) {
      return VoiceIntent.breathing;
    }
    if (_has(t, ["i'm okay", 'im okay', 'i am okay', 'i am ok', 'continue',
        'keep going', "i'm fine", 'im fine'])) {
      return VoiceIntent.imOkay;
    }

    // Walk control.
    if (_has(t, ['end walk', 'stop walk', 'finish walk', 'end my walk',
        'done walking', 'end the walk'])) {
      return VoiceIntent.endWalk;
    }
    if (_has(t, ['start walk', 'begin walk', 'start a walk', 'start my walk',
        'lets walk', "let's walk", 'go for a walk', 'start'])) {
      return VoiceIntent.startWalk;
    }

    // Navigation.
    if (_has(t, ['home'])) return VoiceIntent.goHome;
    if (_has(t, ['progress', 'stats', 'statistics'])) {
      return VoiceIntent.goProgress;
    }
    if (_has(t, ['profile', 'my info', 'account'])) return VoiceIntent.goProfile;
    if (_has(t, ['settings', 'preferences', 'options'])) {
      return VoiceIntent.goSettings;
    }

    // Help.
    if (_has(t, ['help', 'what can i say', 'repeat', 'options', 'commands'])) {
      return VoiceIntent.help;
    }

    return VoiceIntent.unknown;
  }
}
