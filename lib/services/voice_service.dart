import 'package:flutter_tts/flutter_tts.dart';

/// Service for text-to-speech voice guidance
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isMuted = false;
  bool _isInitialized = false;

  /// Initialize the TTS engine
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5); // Normal speech rate
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _isInitialized = true;
  }

  /// Speak navigation instruction
  Future<void> speak(String text) async {
    if (_isMuted || !_isInitialized) return;

    await _flutterTts.speak(text);
  }

  /// Stop current speech
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Toggle mute/unmute
  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      // Fire and forget - we don't want to block on stop
      stop().catchError((error) {
        // Silently handle errors during stop
      });
    }
  }

  /// Check if muted
  bool get isMuted => _isMuted;

  /// Set muted state
  void setMuted(bool muted) {
    _isMuted = muted;
    if (_isMuted) {
      // Fire and forget - we don't want to block on stop
      stop().catchError((error) {
        // Silently handle errors during stop
      });
    }
  }

  /// Dispose resources
  /// Note: This cannot be async, so we handle the future without awaiting
  void dispose() {
    // Fire and forget - dispose cannot be async
    _flutterTts.stop().catchError((error) {
      // Silently handle errors during disposal
    });
  }
}

