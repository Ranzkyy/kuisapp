import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "title": "Selamat Datang di KuisMan",
      "desc": "Belajar sambil bermain kuis, pengalaman seru yang tak terlupakan!",
      "icon": Icons.school,
      "color": Colors.blueAccent
    },
    {
      "title": "Kuis Menantang",
      "desc": "Uji pengetahuanmu dengan soal-soal seru setiap hari.",
      "icon": Icons.quiz_rounded,
      "color": Colors.orangeAccent
    },
    {
      "title": "Mulai Sekarang!",
      "desc": "Tekan tombol mulai dan jadilah juara kuis!",
      "icon": Icons.rocket_launch_rounded,
      "color": Colors.green
    },
  ];

  void finishOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboarded', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF133E87); // Warna utama KuisMan

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: pages[index]["color"],
                          child: Icon(
                            pages[index]["icon"],
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          pages[index]["title"],
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          pages[index]["desc"],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  width: currentPage == index ? 22 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: currentPage == index ? primaryColor : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (currentPage == pages.length - 1) {
                      finishOnboarding();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    currentPage == pages.length - 1 ? "Mulai" : "Selanjutnya",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
