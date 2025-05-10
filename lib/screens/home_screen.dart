import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '/services/audio_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FileSystemEntity> _audioFiles = [];
  final AudioService _audioService = AudioService();
  int? _currentSongIndex;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _shuffle = false;
  bool _repeat = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _audioService.setOnStateChanged(() {
      setState(() {
        _isPlaying = _audioService.isPlaying;
        _position = _audioService.position;
        _duration = _audioService.duration;
        _shuffle = _audioService.shuffle;
        _repeat = _audioService.repeat;
      });
    });
  }

  // Request storage permissions
  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [
          Permission.storage, // Android 12 and below
          if (Platform.isAndroid && (await _getAndroidVersion()) >= 33)
            Permission.audio, // Android 13+
        ].request();

    if (statuses[Permission.storage]!.isGranted ||
        (statuses[Permission.audio]?.isGranted ?? false)) {
      await _loadAudioFiles();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please grant storage permission to load music."),
          action: SnackBarAction(
            label: "Settings",
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
  }

  // Helper to get Android SDK version
  Future<int> _getAndroidVersion() async {
    try {
      final String version =
          await Platform.isAndroid
              ? (await (await Process.run('getprop', [
                    'ro.build.version.sdk',
                  ])).stdout)
                  .trim()
              : '0';
      return int.parse(version);
    } catch (e) {
      return 0;
    }
  }

  // Load audio files from the Music directory
  Future<void> _loadAudioFiles() async {
    try {
      final musicDir = Directory('/storage/emulated/0/Music');
      if (await musicDir.exists()) {
        List<FileSystemEntity> files = [];
        await for (var file in musicDir.list(recursive: true)) {
          if (file is File && file.path.endsWith('.mp3')) {
            files.add(file);
          }
        }
        setState(() {
          _audioFiles = files;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Music directory not found.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading music files.")),
      );
    }
  }

  // Play a song
  void _playSong(int index) async {
    try {
      _currentSongIndex = index;
      await _audioService.play(_audioFiles[index].path);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error playing music.")));
    }
  }

  // Play next song
  void _playNext() {
    if (_currentSongIndex == null || _audioFiles.isEmpty) return;
    int nextIndex;
    if (_shuffle) {
      nextIndex = Random().nextInt(_audioFiles.length);
    } else {
      nextIndex = (_currentSongIndex! + 1) % _audioFiles.length;
    }
    _playSong(nextIndex);
  }

  // Play previous song
  void _playPrevious() {
    if (_currentSongIndex == null || _audioFiles.isEmpty) return;
    int prevIndex;
    if (_shuffle) {
      prevIndex = Random().nextInt(_audioFiles.length);
    } else {
      prevIndex =
          (_currentSongIndex! - 1) >= 0
              ? _currentSongIndex! - 1
              : _audioFiles.length - 1;
    }
    _playSong(prevIndex);
  }

  // Format duration as mm:ss
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Premium Music Player'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Now Playing Section
            if (_currentSongIndex != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.music_note,
                        size: 100,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _audioFiles[_currentSongIndex!].uri.pathSegments.last,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Seek Bar
                    Slider(
                      value: _position.inSeconds.toDouble(),
                      max:
                          _duration.inSeconds.toDouble() > 0
                              ? _duration.inSeconds.toDouble()
                              : 1.0,
                      onChanged: (value) {
                        _audioService.seek(Duration(seconds: value.toInt()));
                      },
                      activeColor: Colors.blueAccent,
                      inactiveColor: Colors.white30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Playback Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            _shuffle ? Icons.shuffle : Icons.shuffle_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _audioService.toggleShuffle();
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                          ),
                          onPressed: _playPrevious,
                        ),
                        IconButton(
                          icon: Icon(
                            _isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Colors.white,
                            size: 48,
                          ),
                          onPressed: () {
                            if (_isPlaying) {
                              _audioService.pause();
                            } else if (_currentSongIndex != null) {
                              _audioService.resume();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            color: Colors.white,
                          ),
                          onPressed: _playNext,
                        ),
                        IconButton(
                          icon: Icon(
                            _repeat ? Icons.repeat_one : Icons.repeat,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _audioService.toggleRepeat();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            // Song List
            Expanded(
              child:
                  _audioFiles.isEmpty
                      ? const Center(
                        child: Text(
                          "No music files found.",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _audioFiles.length,
                        itemBuilder: (context, index) {
                          final file = _audioFiles[index];
                          return Card(
                            color: Colors.white10,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                file.uri.pathSegments.last,
                                style: const TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: const Icon(
                                Icons.music_note,
                                color: Colors.white70,
                              ),
                              onTap: () => _playSong(index),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:
              _audioFiles.isEmpty
                  ? null
                  : () {
                    _audioService.toggleShuffle();
                    _playSong(Random().nextInt(_audioFiles.length));
                  },
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.shuffle),
        ),
      ),
    );
  }
}
