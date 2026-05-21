import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  static const List<Map<String, String>> _onboardingData = [
    {
      "title": "Mọi thứ bạn yêu thích,\ntrên cùng một ứng dụng",
      "subtitle": "Khám phá hàng triệu sản phẩm\nvới mức giá tốt nhất.",
      "image": "assets/images/onboarding1.png",
    },
    {
      "title": "Thanh toán an toàn,\nHoàn toàn an tâm",
      "subtitle": "Đa dạng phương thức thanh toán\ntiện lợi và bảo mật.",
      "image": "assets/images/onboarding3.png",
    },
    {
      "title": "Giao hàng siêu tốc\nTận cửa nhà bạn",
      "subtitle": "Nhận hàng nhanh chóng với dịch vụ\ngiao hàng hỏa tốc của chúng tôi.",
      "image": "assets/images/onboarding2.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _onNext() async {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await AuthService().setFirstLaunchCompleted();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _onSkip() async {
    await AuthService().setFirstLaunchCompleted();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: TextButton(
                  onPressed: _onSkip,
                  child: const Text(
                    'Bỏ qua',
                    style: TextStyle(
                      color: Color(0xFF265B73),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => _OnboardingPage(
                  data: _onboardingData[index],
                ),
              ),
            ),
            _DotIndicator(count: _onboardingData.length, currentIndex: _currentPage),
            const SizedBox(height: 24),
            _buildButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF265B73),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text(
            _currentPage == _onboardingData.length - 1 ? 'Bắt Đầu Mua Sắm' : 'Tiếp tục',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _DotIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentIndex ? const Color(0xFF265B73) : const Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final Map<String, String> data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                data["image"]!,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data["title"]!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data["subtitle"]!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
