import 'package:flutter/material.dart';

import '../widgets/home_header.dart';
import '../widgets/home_banner_carousel.dart';
import '../widgets/home_categories.dart';
import '../widgets/home_new_arrivals.dart';
import '../widgets/home_recommendations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(),
              HomeBannerCarousel(),
              SizedBox(height: 30),
              HomeCategories(),
              SizedBox(height: 30),
              HomeNewArrivals(),
              SizedBox(height: 30),
              HomeRecommendations(),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
