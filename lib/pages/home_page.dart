import 'package:flutter/material.dart';
import '../widgets/course_card.dart';
import 'module_page.dart';
import '../services/certificate_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CertificateService _certificateService = CertificateService();
  String _userName = '';

  final List<Map<String, dynamic>> courses = const [
    {
      'title': 'Flutter Development for Beginners',
      'instructor': 'Jane Doe',
      'imageUrl':
          'https://images.pexels.com/photos/1181677/pexels-photo-1181677.jpeg',
      'rating': 4.7,
    },
    {
      'title': 'Advanced Dart Programming',
      'instructor': 'John Smith',
      'imageUrl':
          'https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg',
      'rating': 4.8,
    },
    {
      'title': 'UI/UX Design Principles',
      'instructor': 'Anna Lee',
      'imageUrl':
          'https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg',
      'rating': 4.6,
    },
    {
      'title': 'Fullstack Mobile App Development',
      'instructor': 'David Kim',
      'imageUrl':
          'https://images.pexels.com/photos/1181300/pexels-photo-1181300.jpeg',
      'rating': 4.9,
    },
  ];

  final List<Map<String, String>> carouselItems = const [
    {
      'imageUrl':
          'https://images.pexels.com/photos/1181677/pexels-photo-1181677.jpeg',
      'text': 'Master Flutter Development',
    },
    {
      'imageUrl':
          'https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg',
      'text': 'Advanced Dart Techniques',
    },
    {
      'imageUrl':
          'https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg',
      'text': 'Design Like a Pro',
    },
  ];

  late final List<Map<String, String>> loopedCarouselItems;
  late final PageController _pageController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredCourses = [];
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    loopedCarouselItems = [
      carouselItems.last,
      ...carouselItems,
      carouselItems.first,
    ];
    _pageController = PageController(initialPage: 1, viewportFraction: 0.9);
    filteredCourses = courses;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
    });
  }

  void _filterCourses(String query) {
    setState(() {
      filteredCourses = courses.where((course) {
        final title = course['title'].toString().toLowerCase();
        final instructor = course['instructor'].toString().toLowerCase();
        final input = query.toLowerCase();
        return title.contains(input) || instructor.contains(input);
      }).toList();
    });
  }

  void _handlePageChanged(int page) {
    int itemCount = carouselItems.length;
    if (page == 0) {
      _pageController.jumpToPage(itemCount);
      setState(() {
        _currentCarouselIndex = itemCount - 1;
      });
    } else if (page == itemCount + 1) {
      _pageController.jumpToPage(1);
      setState(() {
        _currentCarouselIndex = 0;
      });
    } else {
      setState(() {
        _currentCarouselIndex = page - 1;
      });
    }
  }

  void _openModulePage(String moduleTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModulePage(
          moduleTitle: moduleTitle,
          chapters: [
            Chapter(
              title: 'Introduction',
              duration: '10 min',
              content: 'Welcome to this course! In this chapter, we will introduce you to the basic concepts and get you started with your learning journey.',
            ),
            Chapter(
              title: 'Setup & Installation',
              duration: '15 min',
              content: 'Learn how to set up your development environment and install all necessary tools to begin your development journey.',
            ),
            Chapter(
              title: 'Widgets Basics',
              duration: '20 min',
              content: 'Understanding the fundamental building blocks of Flutter applications - Widgets. Learn about different types of widgets and how to use them effectively.',
              isCompleted: true,
            ),
            Chapter(
              title: 'State Management',
              duration: '25 min',
              content: 'Master the art of managing state in Flutter applications. Learn about different state management solutions and when to use them.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: loopedCarouselItems.length,
            onPageChanged: _handlePageChanged,
            itemBuilder: (context, index) {
              final item = loopedCarouselItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item['imageUrl']!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFF5F6FA),
                          child: const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black54, Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Text(
                          item['text']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.black87,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(carouselItems.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentCarouselIndex == index ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentCarouselIndex == index
                    ? const Color(0xFF6C63FF)
                    : const Color(0xFF6C63FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAllCoursesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredCourses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
        return GestureDetector(
          onTap: () => _openModulePage(course['title']),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    course['imageUrl'],
                    width: 100,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 80,
                      color: const Color(0xFFF5F6FA),
                      child: const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'By ${course['instructor']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            course['rating'].toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, $_userName',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'KuisApp',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 24),
            _buildCarousel(),
            const SizedBox(height: 24),
            const Text(
              'Popular Courses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: courses.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return GestureDetector(
                    onTap: () => _openModulePage(course['title']),
                    child: CourseCard(
                      title: course['title'],
                      instructor: course['instructor'],
                      imageUrl: course['imageUrl'],
                      rating: course['rating'],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterCourses,
                decoration: InputDecoration(
                  hintText: 'Search courses...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF6C63FF)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'All Courses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 12),
            _buildAllCoursesList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHomeContent(),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
    );
  }
}
