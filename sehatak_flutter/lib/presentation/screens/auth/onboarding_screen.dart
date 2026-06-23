import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _page = 0;
  final _pages = [
    {'icon': Icons.health_and_safety, 'title': 'صحتك أولاً', 'desc': 'منصة الرعاية الصحية الشاملة\nاستشر الأطباء واحجز مواعيدك بسهولة', 'gradient': AppColors.primaryGradient},
    {'icon': Icons.local_pharmacy, 'title': 'صيدلية متكاملة', 'desc': 'اطلب أدويتك واستلمها لمنزلك\nمع توصيل سريع وآمن', 'gradient': AppColors.secondaryGradient},
    {'icon': Icons.medical_services, 'title': 'رعاية متواصلة', 'desc': 'متابعة صحية شاملة وتحاليل مخبرية\nوخدمات طوارئ على مدار الساعة', 'gradient': AppColors.medicalGradient},
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      SharedPreferences.getInstance().then((p) => p.setBool('onboarding_shown', false));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext c) {
    final colors = _pages[_page]['gradient'] as List<Color>;
    return Scaffold(
      body: AnimatedContainer(duration: const Duration(milliseconds: 500), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors)),
        child: SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), child: Row(children: [
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: (_page + 1) / _pages.length, backgroundColor: Colors.white.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation(Colors.white), minHeight: 4))),
            const SizedBox(width: 12), Text('${_page + 1}/${_pages.length}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
          ])),
          Expanded(child: PageView.builder(controller: _pageCtrl, onPageChanged: (i) => setState(() => _page = i), itemCount: _pages.length, itemBuilder: (_, i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 160, height: 160, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle), child: Icon(_pages[i]['icon'] as IconData, size: 80, color: Colors.white)),
            const SizedBox(height: 50),
            Text(_pages[i]['title'] as String, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo'), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(_pages[i]['desc'] as String, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.85), height: 1.6, fontFamily: 'Cairo'), textAlign: TextAlign.center),
          ])))),
          Padding(padding: const EdgeInsets.all(32), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_pages.length, (i) => AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: _page == i ? 28 : 8, height: 8, decoration: BoxDecoration(color: _page == i ? Colors.white : Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(4))))),
            const SizedBox(height: 40),
            SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: _next, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: colors[0], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(_page == _pages.length - 1 ? 'ابدأ الآن' : 'التالي', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
          ])),
        ])),
      ),
    );
  }
}
