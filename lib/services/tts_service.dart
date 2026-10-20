
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setLanguage('en-US');
  }

  Future<void> speak(String message) async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    // Keep announcements audible over music and allow music to resume.
    await _tts.setAudioAttributesForNavigation();
    await _tts.speak(message, focus: true);
  }
}
