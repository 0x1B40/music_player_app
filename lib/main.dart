import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Music Player',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MusicPlayer(),
    );
  }
}

class MusicPlayer extends StatefulWidget {
  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;

  void _playMusic() async {
    await _audioPlayer.play(AssetSource('audio/sample.mp3'));
    setState(() => isPlaying = true);
  }

  void _pauseMusic() async {
    await _audioPlayer.pause();
    setState(() => isPlaying = false);
  }

  void _stopMusic() async {
    await _audioPlayer.stop();
    setState(() => isPlaying = false);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Music Player')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Now Playing: sample.mp3'),
            SizedBox(height: 20),
            Icon(Icons.music_note, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isPlaying ? null : _playMusic,
                  child: Text('Play'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isPlaying ? _pauseMusic : null,
                  child: Text('Pause'),
                ),
                SizedBox(width: 10),
                ElevatedButton(onPressed: _stopMusic, child: Text('Stop')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
