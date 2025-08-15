import 'package:flutter/material.dart';
import 'package:sync2sing/features/curriculum/logics/song_detail_model.dart';

class DuetSongDetailPage extends StatelessWidget {
  final SongDetailModel songDetailModel;
  final List<DuetPart> duetParts;
  const DuetSongDetailPage({super.key, required this.songDetailModel, required this.duetParts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("DuetSongDetailPage - ${songDetailModel.title} | ${duetParts.first.partName}"),
    );
  }
}
