# aria — *keep your life's rhythm*

A Flutter (Android-first) app for the AI4Good Lab that helps people with
Parkinson's disease walk. Wearable IMU sensors stream gait data; an on-device
ML model predicts **freezing of gait (FoG)**; a **continuous** rhythmic audio
cue keeps the user in tempo; and on a predicted/active freeze the app surfaces
an **intervention** (breathing, call emergency contact, call support line,
"I'm okay"). A hands-free **speech-assist** mode lets a voice agent operate the
app.

> The Flutter app lives on the **`flutter-app`** branch. The `main` branch holds
> the Python ML pipeline (`prepare_data.py`, `CNN_BiLSTM.py`) and is kept
> separate on purpose.

---

## Architecture — five swappable seams

Everything that touches hardware, the model, audio, or voice sits behind an
interface with a **mock** implementation, so the entire pipeline runs on the
emulator with no hardware and no trained model. Going to production is a
one-line provider swap in `lib/providers/providers.dart`.

| Seam | Interface | Mock (now) | Real (later) |
|---|---|---|---|
| Sensors | `SensorSource` | `MockSensorSource` (synthetic 60 Hz / 24 ch) | `BleSensorSource` (flutter_blue_plus) |
| Model | `FogModel` | `MockFogModel` (scripted states) | `TfliteFogModel` (tflite_flutter) |
| Cue | `CueEngine` | `MetronomeCueEngine` (runtime-generated click loop) | tempo-matched music |
| Intervention | `InterventionManager` | `DefaultInterventionManager` | — |
| Voice | `VoiceAssistant` | `MockVoiceAssistant` | `KeywordVoiceAssistant` (speech_to_text + flutter_tts) |

A `SessionController` (Riverpod `Notifier`) wires them:

```
SensorSource.samples ─▶ WindowBuffer(120×24) ─▶ FogModel.predict (every 1 s)
       ─▶ FogState ─▶ session state machine ─▶ CueEngine (continuous)
                                            └▶ InterventionManager ─▶ UI
```

The UI reads an immutable `SessionSnapshot` and never touches raw sensor data.

### Folder layout (`lib/`)
- `core/` — `theme/tokens.dart` (all design tokens), `theme/app_theme.dart`,
  `a11y/a11y.dart` (cited accessibility constants), `sensor_schema.dart`.
- `data/models/` — `ImuSample`, `FogPrediction`/`FogState`, `SensorStatus`.
- `services/` — `sensors/`, `model/`, `cue/`, `intervention/`, `voice/`,
  `session/` (state machine + ring buffer).
- `providers/` — Riverpod wiring (mock-vs-real lives here).
- `features/` — one folder per screen (`home/`, `session/`, …).
- `widgets/` — reusable UI (`PulseRing`, `GradientButton`, …).

---

## The sensor / feature contract (must match the model)

`lib/core/sensor_schema.dart` mirrors `prepare_data.py` **exactly**:

- 4 sensor locations: **left ankle, right ankle, lower back, wrist**
- each: accel (x,y,z) + gyro (x,y,z) = 6 channels → **24 features / timestep**
- sample rate **60 Hz**, sliding window **120** samples (2 s), step **60** (1 s)
- `kFeatureOrder` is the canonical column order — identical to `SENSOR_COLS`.

The trained model is **binary** (freeze / no-freeze). The app maps its
probability into `normal | preFreeze | freezing` via `FogThresholds`
(`p<0.40 → normal`, `0.40–0.70 → preFreeze`, `≥0.70 → freezing`) to act with
lead time. Retune these once a real model + measured lead time exist.

---

## Run it on an Android emulator (macOS, no physical phone)

> BLE does **not** work in the emulator — sensors need a real phone. Everything
> mock-based (the whole M1 flow) runs fully on an AVD.

1. **Flutter SDK:** `brew install --cask flutter` → `flutter --version`.
2. **Android Studio:** `brew install --cask android-studio`. Open it once; in
   the Setup Wizard install **Android SDK**, an **SDK Platform** (API 34/35),
   **SDK Command-line Tools**, **Platform-Tools**, and the **Android Emulator**.
3. **JDK:** `flutter config --jdk-dir "/Applications/Android Studio.app/Contents/jbr/Contents/Home"`.
4. **Licenses:** `flutter doctor --android-licenses` (accept all), then
   `flutter doctor` until the Android toolchain is ✓.
5. **AVD:** Android Studio ▸ Device Manager ▸ Create Device (e.g. Pixel 7).
6. **Run:** boot the AVD, then `flutter run`. Hot reload = `r`, hot restart = `R`.
7. **VS Code:** install the Flutter + Dart extensions.

Verify (`flutter analyze` is clean, `flutter test` passes):
- Home → tap the **Start walk** ring → Walking screen with an **audible
  continuous metronome**;
- after ~10 s the scripted model enters preFreeze→freezing and the
  **Intervention** screen appears;
- choose **"I'm okay, continue"** → returns to walking; **End walk** → Home.

---

## Teammate plug-in points

### 1. Real sensors (`BleSensorSource`)
Implement the stub in `lib/services/sensors/ble_sensor_source.dart` with
`flutter_blue_plus`: scan/connect the 4 Arduino Nano 33 BLE boards, subscribe to
the IMU notify characteristic, decode each packet into the **24-feature vector
in `kFeatureOrder`** at ~60 Hz, and add it to `samples`. Then in
`providers.dart` change `sensorSourceProvider` from `MockSensorSource` to
`BleSensorSource`. Test on a real phone (add BLE + location permissions).

### 2. Trained model (`TfliteFogModel`)
1. Export the Keras model to `assets/models/fog_model.tflite` and declare the
   asset in `pubspec.yaml`.
2. Implement `lib/services/model/tflite_fog_model.dart` with `tflite_flutter`:
   load the interpreter, reshape the window to `[1, 120, 24]`, run, read the FoG
   probability, map via `FogThresholds`.
3. **Normalisation (important):** `prepare_data.py` scales features
   **per-subject** with `StandardScaler`. Inference must apply equivalent
   normalisation — bake it into the graph, or export mean/std and normalise the
   window in `predict()` — otherwise inputs won't match training.
4. Swap `fogModelProvider` to `TfliteFogModel`.

### 3. Tempo-matched music
Implement the `playTrack` extension point on `CueEngine` (the
continuous-cue contract already fits). The metronome is just the MVP cue.

---

## Accessibility

Users have Parkinson's (tremor, bradykinesia, possible visual/cognitive
changes; many older adults). Rules are encoded in `lib/core/a11y/a11y.dart`,
each citing its source:
- **≥56 dp tap targets**, ≥16 dp apart (exceeds WCAG 2.2 §2.5.5 / Material 48 dp
  for tremor) — Nunes et al., Springer **10.1007/s10209-015-0440-1**.
- **No fine-motor gestures** (taps only — no swipe/drag/double-tap/pinch).
- **High contrast + large type** (WCAG 2.2 §1.4.3 / §1.4.4).
- **One primary action per screen**; **colour never the only signal**
  (icon + label always paired).
- **Voice-first** speech-assist as a tremor-friendly path.

---

## Milestones
- **M1 (done):** mock end-to-end — synthetic data → mock model → continuous
  metronome → state machine → intervention, on the emulator.
- **M2:** full UI (all onboarding + Home/Progress/Profile/Settings + beat
  picker + summary), floating nav, persistence, `audio_service` background play.
- **M3:** speech-assist voice agent (real STT/TTS).
- **M4:** real BLE + TFLite + tempo-matched music.

State management is **Riverpod**; light theme only.
