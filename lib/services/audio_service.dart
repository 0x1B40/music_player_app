import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() => _instance;

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _shuffle = false;
  bool _repeat = false;

  AudioService._internal() {
    _player.onDurationChanged.listen((d) {
      _duration = d;
      _notifyListeners();
    });
    _player.onPositionChanged.listen((p) {
      _position = p;
      _notifyListeners();
    });
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _notifyListeners();
    });
  }

  Function()? _onStateChanged;

  void setOnStateChanged(Function() callback) {
    _onStateChanged = callback;
  }

  void _notifyListeners() {
    _onStateChanged?.call();
  }

  Future<void> play(String uri) async {
    await _player.stop();
    await _player.play(DeviceFileSource(uri));
    _isPlaying = true;
    _notifyListeners();
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
    _notifyListeners();
  }

  Future<void> resume() async {
    await _player.resume();
    _isPlaying = true;
    _notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _position = Duration.zero;
    _notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _position = position;
    _notifyListeners();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    _notifyListeners();
  }

  void toggleRepeat() {
    _repeat = !_repeat;
    _notifyListeners();
  }

  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get shuffle => _shuffle;
  bool get repeat => _repeat;
}