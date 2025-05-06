import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

class SignupProfileInfoPage extends StatelessWidget {
  const SignupProfileInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("SignupProfileInfoPage", style: AppTextStyles.display1),
      ),
    );
  }
}
