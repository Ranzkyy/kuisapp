import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chapter_content_page.dart';
import 'quiz_page.dart';
import '../services/certificate_service.dart';

class Chapter {
  final String title;
  final String duration;
  final String content;
  bool isCompleted;

  Chapter({
    required this.title,
    required this.duration,
    required this.content,
    this.isCompleted = false,
  });
}

class ModulePage extends StatefulWidget {
  final String moduleTitle;
  final List<Chapter> chapters;

  const ModulePage({
    Key? key,
    required this.moduleTitle,
    required this.chapters,
  }) : super(key: key);

  @override
  State<ModulePage> createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  late List<Chapter> _chapters;
  bool _allChaptersCompleted = false;
  bool _quizCompleted = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _chapters = List.from(widget.chapters);
    _loadCompletionStatus();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
    });
  }

  Future<void> _loadCompletionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    for (var i = 0; i < _chapters.length; i++) {
      final isCompleted = prefs.getBool('${widget.moduleTitle}_chapter_$i') ?? false;
      _chapters[i].isCompleted = isCompleted;
    }
    _checkAllChaptersCompleted();
    _quizCompleted = prefs.getBool('allQuizzesCompleted') ?? false;
    setState(() {});
  }

  Future<void> _updateChapterCompletion(int index, bool isCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${widget.moduleTitle}_chapter_$index', isCompleted);
    _chapters[index].isCompleted = isCompleted;
    _checkAllChaptersCompleted();
    setState(() {});
  }

  void _checkAllChaptersCompleted() {
    _allChaptersCompleted = _chapters.every((chapter) => chapter.isCompleted);
    if (_allChaptersCompleted) {
      _updateAllChaptersCompleted();
    }
  }

  Future<void> _updateAllChaptersCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('allChaptersCompleted', true);
  }

  double get _completionPercentage {
    if (_chapters.isEmpty) return 0;
    final completedChapters =
        _chapters.where((chapter) => chapter.isCompleted).length;
    return completedChapters / _chapters.length;
  }

  Future<void> _openChapter(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterContentPage(
          chapter: _chapters[index],
          chapterIndex: index,
          totalChapters: _chapters.length,
          moduleTitle: widget.moduleTitle,
          onNavigateChapter: (newIndex) {
            Future.delayed(Duration(milliseconds: 200), () {
              _openChapter(newIndex);
            });
          },
        ),
      ),
    );
    await _loadCompletionStatus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool canDownloadCertificate = _allChaptersCompleted && _quizCompleted;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          widget.moduleTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6C63FF), Color(0xFF4A45B1)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizPage(
                    moduleTitle: widget.moduleTitle,
                  ),
                ),
              ).then((_) => _loadCompletionStatus());
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
            itemCount: _chapters.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final chapter = _chapters[index];
              return Container(
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
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF4A45B1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    chapter.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          chapter.duration,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: chapter.isCompleted
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            color: Colors.grey[600],
                            size: 24,
                          ),
                        ),
                  onTap: () async {
                    await _openChapter(index);
                  },
                ),
              );
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progres Belajar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(_completionPercentage * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _completionPercentage,
                      backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                      minHeight: 8,
                    ),
                  ),
                  if (canDownloadCertificate) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await CertificateService().generateAndShareCertificate(
                              userName: _userName,
                              courseName: widget.moduleTitle,
                              completionDate: DateTime.now(),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sertifikat berhasil dibuat dan siap dibagikan!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal membuat sertifikat: $e')),
                            );
                          }
                        },
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: const Text(
                          'Download Sertifikat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}