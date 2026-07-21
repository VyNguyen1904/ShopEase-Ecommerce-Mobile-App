import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/register_header.dart';
import '../widgets/register_form.dart';
import '../widgets/register_footer.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
              RegisterHeader(),
              SizedBox(height: 36),
              RegisterForm(),
              SizedBox(height: 24),
              RegisterFooter(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
