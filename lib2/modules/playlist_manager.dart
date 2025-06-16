import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class PlaylistManager {
  List<Map<String, dynamic>> _playlists = [];

  List<Map<String, dynamic>> get playlists => _playlists;

  // Load playlists from local storage
  Future<void> loadPlaylists() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/playlists.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        _playlists = List<Map<String, dynamic>>.from(jsonDecode(content));
      }
    } catch (e) {
      throw Exception('Error loading playlists: $e');
    }
  }

  // Save playlists to local storage
  Future<void> savePlaylists() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/playlists.json');
      await file.writeAsString(jsonEncode(_playlists));
    } catch (e) {
      throw Exception('Error saving playlists: $e');
    }
  }

  // Create a new playlist
  void createPlaylist(BuildContext context, String name) {
    if (name.isNotEmpty) {
      _playlists.add({'name': name, 'songs': <int>[]});
      savePlaylists().catchError((e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
  }

  // Add song to playlist
  void addSongToPlaylist(
    BuildContext context,
    String playlistName,
    int songIndex,
  ) {
    final playlist = _playlists.firstWhere((p) => p['name'] == playlistName);
    if (!playlist['songs'].contains(songIndex)) {
      playlist['songs'].add(songIndex);
      savePlaylists().catchError((e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
  }
}
