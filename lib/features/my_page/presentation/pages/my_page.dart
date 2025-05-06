import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("MyPage", style: AppTextStyles.display1)),
    );
  }
}
