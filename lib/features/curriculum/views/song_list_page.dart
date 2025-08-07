import 'package:flutter/material.dart';

class SongListPage extends StatelessWidget {
  final String type; // enum 으로 수정해도 좋을 듯.

  const SongListPage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("SongListPage - $type")));
  }
}
