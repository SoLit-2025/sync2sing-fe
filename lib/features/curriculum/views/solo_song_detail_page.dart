import 'package:flutter/material.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';

class SoloSongDetailPage extends StatelessWidget {
  final SongDetailModel songDetailModel;
  const SoloSongDetailPage({super.key, required this.songDetailModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("SoloSongDetailPage - ${songDetailModel.title}")));
  }
}
