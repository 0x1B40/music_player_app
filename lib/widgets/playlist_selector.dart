import 'package:flutter/material.dart';

class PlaylistSelector extends StatelessWidget {
  final List<Map<String, dynamic>> playlists;
  final String? selectedPlaylistName;
  final Function(String?) onChanged;

  const PlaylistSelector({
    super.key,
    required this.playlists,
    required this.selectedPlaylistName,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownButton<String>(
        value: selectedPlaylistName ?? playlists[0]['name'],
        onChanged: onChanged,
        items:
            playlists.map((playlist) {
              return DropdownMenuItem<String>(
                value: playlist['name'],
                child: Text(
                  playlist['name'],
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
        dropdownColor: Colors.grey[800],
        style: const TextStyle(color: Colors.white),
        isExpanded: true,
      ),
    );
  }
}
