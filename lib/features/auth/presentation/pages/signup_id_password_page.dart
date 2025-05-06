import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sync2sing/config/theme/app_text_styles.dart';

class SignupIdPasswordPage extends StatelessWidget {
  const SignupIdPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("SignupIdPasswordPage", style: AppTextStyles.display1),
      ),
    );
  }
}
