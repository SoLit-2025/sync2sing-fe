import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

class Loginpage extends StatelessWidget {
  const Loginpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Loginpage", style: AppTextStyles.display1)),
    );
  }
}
