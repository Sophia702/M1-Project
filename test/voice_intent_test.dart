import 'package:flutter_test/flutter_test.dart';

import 'package:aria/services/voice/voice_intent.dart';

void main() {
  const p = VoiceIntentParser();

  test('maps core commands', () {
    expect(p.parse('start walk'), VoiceIntent.startWalk);
    expect(p.parse('please end my walk'), VoiceIntent.endWalk);
    expect(p.parse("i'm okay"), VoiceIntent.imOkay);
    expect(p.parse('lets do a breathing exercise'), VoiceIntent.breathing);
    expect(p.parse('call my contact'), VoiceIntent.callEmergency);
    expect(p.parse('call the support line'), VoiceIntent.callSupport);
    expect(p.parse('go to settings'), VoiceIntent.goSettings);
    expect(p.parse('open progress'), VoiceIntent.goProgress);
    expect(p.parse('stop listening'), VoiceIntent.disableVoice);
  });

  test('yes/no are word-bounded (not substrings)', () {
    expect(p.parse('yes'), VoiceIntent.yes);
    expect(p.parse('no'), VoiceIntent.no);
    // "now" must NOT be read as "no".
    expect(p.parse('open progress now'), VoiceIntent.goProgress);
  });

  test('unknown for gibberish', () {
    expect(p.parse('banana helicopter'), VoiceIntent.unknown);
  });
}
