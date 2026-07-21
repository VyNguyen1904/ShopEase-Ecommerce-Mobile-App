import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_item_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          AppStrings.settings,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionHeader(title: AppStrings.general),
            SettingsItemTile(
              icon: Icons.language,
              title: AppStrings.language,
              trailingText: AppStrings.vietnamese,
              onTap: () {},
            ),
            _buildDivider(),
            SettingsItemTile(
              icon: Icons.monetization_on_outlined,
              title: AppStrings.currency,
              trailingText: AppStrings.vnd,
              onTap: () {},
            ),
            _buildDivider(),
            SettingsItemTile(
              icon: Icons.palette_outlined,
              title: AppStrings.theme,
              trailingText: AppStrings.lightTheme,
              onTap: () {},
              showChevronDown: true,
            ),
            const SizedBox(height: 16),
            const SettingsSectionHeader(title: AppStrings.supportSection),
            SettingsItemTile(
              icon: Icons.help_outline,
              title: AppStrings.helpCenter,
              onTap: () {},
            ),
            _buildDivider(),
            SettingsItemTile(
              icon: Icons.description_outlined,
              title: AppStrings.termsAndConditions,
              onTap: () {},
            ),
            _buildDivider(),
            SettingsItemTile(
              icon: Icons.security_outlined,
              title: AppStrings.privacyPolicy,
              onTap: () {},
            ),
            _buildDivider(),
            SettingsItemTile(
              icon: Icons.info_outline,
              title: AppStrings.aboutApp,
              trailingText: AppStrings.version,
              onTap: () {},
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Divider(height: 1, color: AppColors.border),
    );
  }
}
