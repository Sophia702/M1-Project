import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/session/summary_screen.dart';
import '../../features/session/walking_screen.dart';
import '../../providers/providers.dart';
import '../intervention/intervention_manager.dart';
import '../session/session_state.dart';
import 'voice_intent.dart';

enum VoiceStatus { off, idle, listening, speaking, confirming, unavailable }

/// What the overlay renders.
class VoiceUiState {
  final bool enabled;
  final VoiceStatus status;
  final String caption; // what aria last said / is prompting
  final String lastHeard; // what the user last said

  const VoiceUiState({
    this.enabled = false,
    this.status = VoiceStatus.off,
    this.caption = '',
    this.lastHeard = '',
  });

  VoiceUiState copyWith({
    bool? enabled,
    VoiceStatus? status,
    String? caption,
    String? lastHeard,
  }) =>
      VoiceUiState(
        enabled: enabled ?? this.enabled,
        status: status ?? this.status,
        caption: caption ?? this.caption,
        lastHeard: lastHeard ?? this.lastHeard,
      );
}

/// Pending phone call awaiting a spoken yes/no confirmation.
enum _PendingCall { emergency, support }

const _helpText =
    'You can say: start walk, end walk, home, progress, profile, settings, '
    'breathing, call my contact, or stop listening.';

/// Orchestrates the hands-free loop: narrate → listen → match intent → act →
/// repeat. Drives navigation via [navigatorKey] + [navIndexProvider] and the
/// walk via the session controller. Calls are guarded by a yes/no confirm.
class VoiceController extends Notifier<VoiceUiState> {
  static const _parser = VoiceIntentParser();
  bool _looping = false;
  _PendingCall? _pending;

  @override
  VoiceUiState build() => const VoiceUiState();

  Future<void> enable() async {
    if (state.enabled) return;
    state = state.copyWith(enabled: true, status: VoiceStatus.idle);
    final assistant = ref.read(voiceAssistantProvider);
    final ok = await assistant.init();
    if (!ok) {
      state = state.copyWith(
        status: VoiceStatus.unavailable,
        caption: 'Voice needs a microphone — try on a real device.',
      );
      return;
    }
    await _say('Voice assist on. $_helpText');
    _loop();
  }

  Future<void> disable() async {
    state = state.copyWith(
        enabled: false, status: VoiceStatus.off, caption: '', lastHeard: '');
    _pending = null;
    await ref.read(voiceAssistantProvider).stopListening();
  }

  /// Tap-to-talk fallback: ensure the listen loop is running.
  void listenNow() {
    if (state.enabled && !_looping) _loop();
  }

  Future<void> _say(String text) async {
    state = state.copyWith(status: VoiceStatus.speaking, caption: text);
    await ref.read(voiceAssistantProvider).speak(text);
  }

  Future<void> _loop() async {
    if (_looping) return;
    _looping = true;
    final assistant = ref.read(voiceAssistantProvider);
    while (state.enabled) {
      state = state.copyWith(
          status: _pending != null
              ? VoiceStatus.confirming
              : VoiceStatus.listening);
      final text = await assistant.listenOnce();
      if (!state.enabled) break;
      if (text == null || text.trim().isEmpty) continue;
      state = state.copyWith(lastHeard: text);
      await _handle(_parser.parse(text));
    }
    _looping = false;
  }

  Future<void> _handle(VoiceIntent intent) async {
    // Resolve a pending call confirmation first.
    if (_pending != null) {
      if (intent == VoiceIntent.yes) {
        final p = _pending!;
        _pending = null;
        await _dial(p);
      } else if (intent == VoiceIntent.no) {
        _pending = null;
        await _say('Okay, cancelled.');
      } else {
        await _say('Please say yes or no.');
      }
      return;
    }

    switch (intent) {
      case VoiceIntent.disableVoice:
        await _say('Turning voice off.');
        await disable();
      case VoiceIntent.help:
        await _say(_helpText);
      case VoiceIntent.goHome:
        _goTab(0, 'home');
      case VoiceIntent.goProgress:
        _goTab(1, 'progress');
      case VoiceIntent.goProfile:
        _goTab(2, 'profile');
      case VoiceIntent.goSettings:
        _goTab(3, 'settings');
      case VoiceIntent.startWalk:
        await _startWalk();
      case VoiceIntent.endWalk:
        await _endWalk();
      case VoiceIntent.imOkay:
        await _resolveIntervention(
            InterventionAction.imOkayContinue, "Okay — keep going.");
      case VoiceIntent.breathing:
        await _resolveIntervention(
            InterventionAction.breathing, 'Let’s take a slow breath together.');
      case VoiceIntent.callEmergency:
        _pending = _PendingCall.emergency;
        await _say('Call your emergency contact? Say yes or no.');
      case VoiceIntent.callSupport:
        _pending = _PendingCall.support;
        await _say('Call the support line? Say yes or no.');
      case VoiceIntent.yes:
      case VoiceIntent.no:
      case VoiceIntent.unknown:
        await _say("Sorry, I didn't catch that. Say help for options.");
    }
  }

  void _goTab(int index, String name) {
    navigatorKey.currentState?.popUntil((r) => r.isFirst);
    ref.read(navIndexProvider.notifier).set(index);
    _say('Opening $name.');
  }

  Future<void> _startWalk() async {
    final session = ref.read(sessionControllerProvider);
    if (session.state == SessionState.walkingNormal ||
        session.state == SessionState.intervention) {
      await _say('You’re already walking.');
      return;
    }
    await ref.read(sessionControllerProvider.notifier).startSession(bpm: 108);
    navigatorKey.currentState
        ?.push(MaterialPageRoute(builder: (_) => const WalkingScreen()));
    await _say('Starting your walk. Keep your rhythm. Say end walk when done.');
  }

  Future<void> _endWalk() async {
    final session = ref.read(sessionControllerProvider);
    if (session.state != SessionState.walkingNormal &&
        session.state != SessionState.intervention) {
      await _say('You’re not on a walk right now.');
      return;
    }
    await ref.read(sessionControllerProvider.notifier).endSession();
    navigatorKey.currentState
        ?.pushReplacement(MaterialPageRoute(builder: (_) => const SummaryScreen()));
    await _say('Nice walk. You can say done, or home.');
  }

  Future<void> _resolveIntervention(
      InterventionAction action, String spoken) async {
    final session = ref.read(sessionControllerProvider);
    if (session.state != SessionState.intervention) {
      await _say("There's nothing to respond to right now.");
      return;
    }
    await ref
        .read(sessionControllerProvider.notifier)
        .resolveIntervention(action);
    navigatorKey.currentState?.maybePop(); // close the intervention screen
    await _say(spoken);
  }

  Future<void> _dial(_PendingCall which) async {
    final number = which == _PendingCall.emergency ? '911' : '811';
    final action = which == _PendingCall.emergency
        ? InterventionAction.callEmergencyContact
        : InterventionAction.callSupportLine;
    final session = ref.read(sessionControllerProvider);
    if (session.state == SessionState.intervention) {
      await ref
          .read(sessionControllerProvider.notifier)
          .resolveIntervention(action);
      navigatorKey.currentState?.maybePop();
    }
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
    await _say('Calling now.');
  }
}

final voiceControllerProvider =
    NotifierProvider<VoiceController, VoiceUiState>(VoiceController.new);
