import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sync2sing/features/home_hub/logics/room_item.dart';

class DuetRoomDetailPage extends StatefulWidget {
  final bool isHost;
  final Room room;

  const DuetRoomDetailPage({super.key, required this.isHost, required this.room});

  @override
  State<DuetRoomDetailPage> createState() => _DuetRoomDetailPageState();
}

class _DuetRoomDetailPageState extends State<DuetRoomDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Text("RoomDetailPage")));
  }
}
