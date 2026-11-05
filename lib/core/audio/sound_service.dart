import 'package:flutter/services.dart';

/// Service providing zero-latency sound effects across gameplay and UI.
class SoundService {
  static const MethodChannel _channel = MethodChannel('com.catqueens/sound');
  static bool _muted = false;
  static bool _musicEnabled = true;

  static bool get isMuted => _muted;
  static bool get isMusicEnabled => _musicEnabled;

  static void setMuted(bool muted) {
    _muted = muted;
    _invoke('setMuted', {'muted': muted});
  }

  static void startBgm() => _invoke('startBgm');

  static void stopBgm() => _invoke('stopBgm');

  static void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    _invoke('setMusicEnabled', {'enabled': enabled});
  }

  /// Played on cell tap / marking X
  static void playTap() => _invoke('play', {'sound': 'tap'});

  /// Played when a Queen is placed correctly (sparkle chime)
  static void playQueen() => _invoke('play', {'sound': 'queen'});

  /// Played on Queen placement (cute meow)
  static void playMeow() => _invoke('play', {'sound': 'meow'});

  /// Played on incorrect placement or invalid tap
  static void playError() => _invoke('play', {'sound': 'error'});

  /// Played on level completion
  static void playWin() => _invoke('play', {'sound': 'win'});

  /// Played on UI button clicks
  static void playClick() => _invoke('play', {'sound': 'click'});

  static void _invoke(String method, [dynamic arguments]) {
    if (_muted && method == 'play') return;
    try {
      _channel.invokeMethod(method, arguments).catchError((_) => null);
    } catch (_) {
      // Synchronous catch (e.g. uninitialized ServicesBinding in pure unit tests)
    }
  }
}
