import 'package:flutter/material.dart';

class SongExampleVideoPage extends StatelessWidget {
  final int songId;
  const SongExampleVideoPage({super.key, required this.songId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("SongExampleVideoPage - $songId")));
  }
}
