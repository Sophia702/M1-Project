import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'choose_beat_screen.dart';

/// Opens the session flow: Choose-beat → Walking → Summary.
///
/// Shared by the Home start-ring and the floating-nav centre button so the
/// behaviour is identical from anywhere. The session itself is started on the
/// Choose-beat screen (at the chosen tempo). [ref] is kept for the real flow
/// that will check sensor connection / route to Connect-sensors first.
Future<void> startWalk(BuildContext context, WidgetRef ref) async {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(builder: (_) => const ChooseBeatScreen()),
  );
}
