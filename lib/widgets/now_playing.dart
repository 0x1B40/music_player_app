import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class NowPlaying extends StatelessWidget {
  final int? currentSongIndex;
  final List<SongModel> audioFiles;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool shuffle;
  final bool repeat;
  final VoidCallback onPlayPause;
  final Function(double) onSeek;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onToggleShuffle;
  final VoidCallback onToggleRepeat;

  const NowPlaying({
    super.key,
    required this.currentSongIndex,
    required this.audioFiles,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.shuffle,
    required this.repeat,
    required this.onPlayPause,
    required this.onSeek,
    required this.onNext,
    required this.onPrevious,
    required this.onToggleShuffle,
    required this.onToggleRepeat,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (currentSongIndex == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          QueryArtworkWidget(
            id: audioFiles[currentSongIndex!].id,
            type: ArtworkType.AUDIO,
            artworkBorder: BorderRadius.circular(12),
            artworkWidth: 200,
            artworkHeight: 200,
            nullArtworkWidget: Container(
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
          ),
          const SizedBox(height: 16),
          Text(
            audioFiles[currentSongIndex!].title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Custom Visualizer
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width - 32,
              color: Colors.white30,
              child: CustomPaint(
                painter: WaveformPainter(
                  progress:
                      duration.inSeconds > 0
                          ? position.inSeconds / duration.inSeconds
                          : 0,
                  isPlaying: isPlaying,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Seek Bar
          Slider(
            value: position.inSeconds.toDouble(),
            max:
                duration.inSeconds.toDouble() > 0
                    ? duration.inSeconds.toDouble()
                    : 1.0,
            onChanged: onSeek,
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.white30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                _formatDuration(duration),
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
                  shuffle ? Icons.shuffle : Icons.shuffle_outlined,
                  color: Colors.white,
                ),
                onPressed: onToggleShuffle,
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: onPrevious,
              ),
              IconButton(
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 48,
                ),
                onPressed: onPlayPause,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: onNext,
              ),
              IconButton(
                icon: Icon(
                  repeat ? Icons.repeat_one : Icons.repeat,
                  color: Colors.white,
                ),
                onPressed: onToggleRepeat,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Waveform Painter
class WaveformPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;

  WaveformPainter({required this.progress, required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blueAccent
          ..style = PaintingStyle.fill;

    final bgPaint =
        Paint()
          ..color = Colors.white30
          ..style = PaintingStyle.fill;

    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Simulate waveform with bars
    const barCount = 20;
    final barWidth = size.width / (barCount * 2);
    final maxHeight = size.height * 0.8;

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth * 2 + barWidth;
      final height =
          isPlaying
              ? (maxHeight * (0.5 + 0.5 * (i % 2 == 0 ? 1 : -1) * progress))
                  .abs()
              : maxHeight * 0.5;
      canvas.drawRect(
        Rect.fromLTWH(x, (size.height - height) / 2, barWidth, height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
