import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form.dart';
import '../widgets/login_footer.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 20),
              LoginHeader(),
              SizedBox(height: 36),
              LoginForm(),
              SizedBox(height: 24),
              LoginFooter(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
