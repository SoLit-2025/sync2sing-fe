import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sync2sing/features/curriculum/logics/duet_song_model.dart';

class DuetSongDetailPage extends StatelessWidget {
  final DuetSongModel duetSongModel;
  final bool isSelectFirst;
  const DuetSongDetailPage({super.key, required this.duetSongModel, this.isSelectFirst = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text("duetSongDetailPage - duetSong: ${duetSongModel.title}"));
  }
}
