// Plugin-free unit tests for the M1 pipeline logic (no emulator / audio needed).
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:aria/core/sensor_schema.dart';
import 'package:aria/data/models/fog_prediction.dart';
import 'package:aria/services/intervention/default_intervention_manager.dart';
import 'package:aria/services/intervention/intervention_manager.dart';
import 'package:aria/services/model/mock_fog_model.dart';
import 'package:aria/services/session/ring_buffer.dart';

void main() {
  test('sensor schema is internally consistent', () {
    expect(sensorSchemaIsConsistent, isTrue);
    expect(kFeatureOrder.length, kFeatureCount);
  });

  test('WindowBuffer fills and snapshots oldest->newest', () {
    final buf = WindowBuffer();
    expect(buf.isFull, isFalse);
    for (var i = 0; i < kWindowSize; i++) {
      final row = Float32List(kFeatureCount)..[0] = i.toDouble();
      buf.add(row);
    }
    expect(buf.isFull, isTrue);
    final snap = buf.snapshot();
    expect(snap.length, kWindowSize * kFeatureCount);
    // First row is the oldest (feature[0] == 0), last row newest (== 119).
    expect(snap[0], 0);
    expect(snap[(kWindowSize - 1) * kFeatureCount], kWindowSize - 1);
  });

  test('MockFogModel cycles normal -> preFreeze -> freezing', () {
    final model = MockFogModel();
    final window = Float32List(kWindowSize * kFeatureCount);
    final seen = <FogState>{};
    for (var i = 0; i < 13; i++) {
      seen.add(model.predict(window).state);
    }
    expect(seen, containsAll([FogState.normal, FogState.preFreeze, FogState.freezing]));
  });

  test('InterventionManager raises one request per episode', () async {
    final mgr = DefaultInterventionManager();
    final got = <InterventionRequest>[];
    final sub = mgr.requests.listen(got.add);

    mgr.onFogState(FogState.normal);
    mgr.onFogState(FogState.preFreeze); // fires
    mgr.onFogState(FogState.freezing); // same episode -> no new request
    await Future<void>.delayed(Duration.zero);
    expect(got.length, 1);

    await mgr.resolve(InterventionAction.imOkayContinue); // re-arms
    mgr.onFogState(FogState.freezing); // new episode -> fires again
    await Future<void>.delayed(Duration.zero);
    expect(got.length, 2);

    await sub.cancel();
    await mgr.dispose();
  });
}
