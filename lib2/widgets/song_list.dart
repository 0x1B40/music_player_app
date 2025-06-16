// import 'package:flutter/material.dart';
// import 'package:on_audio_query/on_audio_query.dart';

// class SongList extends StatelessWidget {
//   final List<SongModel> songs;

//   const SongList({super.key, required this.songs});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: songs.length,
//       itemBuilder: (context, index) {
//         final song = songs[index];
//         return ListTile(
//           leading: QueryArtworkWidget(
//             id: song.id,
//             type: ArtworkType.AUDIO,
//             nullArtworkWidget: const Icon(Icons.music_note),
//           ),
//           title: Text(song.title),
//           subtitle: Text(song.artist ?? "Unknown Artist"),
//           onTap: () {
//             // TODO: Play song using audioplayers
//           },
//         );
//       },
//     );
//   }
// }
