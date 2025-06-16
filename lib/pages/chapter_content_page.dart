import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'module_page.dart';

class ChapterContentPage extends StatefulWidget {
  final Chapter chapter;
  final int chapterIndex;
  final int totalChapters;
  final void Function(int)? onNavigateChapter;
  final String moduleTitle;

  const ChapterContentPage({
    Key? key,
    required this.chapter,
    required this.chapterIndex,
    required this.totalChapters,
    required this.moduleTitle,
    this.onNavigateChapter,
  }) : super(key: key);

  @override
  State<ChapterContentPage> createState() => _ChapterContentPageState();
}

class _ChapterContentPageState extends State<ChapterContentPage> {
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.chapter.isCompleted;
  }

  Future<void> _markAsCompleted() async {
    setState(() {
      _isCompleted = true;
    });
    // Update status selesai di SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${widget.moduleTitle}_chapter_${widget.chapterIndex}', true);
    Navigator.pop(context, true); // Return true to indicate completion
  }

  void _navigateToChapter(int newIndex) {
    if (widget.onNavigateChapter != null) {
      widget.onNavigateChapter!(newIndex);
      Navigator.pop(context); // Tutup halaman ini, biar module_page buka yang baru
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          widget.chapter.title,
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Color(0xFF6C63FF),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Duration: ${widget.chapter.duration}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chapter Content',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContentSection(
                    title: 'Overview',
                    content: widget.chapter.content,
                    icon: Icons.info_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildContentSection(
                    title: 'Key Points',
                    content: '• Understanding the basic concepts\n• Learning the fundamental principles\n• Practical examples and exercises\n• Best practices and tips',
                    icon: Icons.lightbulb_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildContentSection(
                    title: 'Practice Exercise',
                    content: 'Complete the following exercises to reinforce your understanding:\n\n1. Review the concepts covered\n2. Try the provided examples\n3. Complete the practice questions\n4. Test your knowledge with the quiz',
                    icon: Icons.assignment_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildContentSection(
                    title: 'Additional Resources',
                    content: '• Official documentation\n• Video tutorials\n• Community forums\n• Sample projects',
                    icon: Icons.link,
                  ),
                ],
              ),
            ),
            if (!_isCompleted)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _markAsCompleted,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text('Tandai Selesai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.chapterIndex > 0
                    ? () => _navigateToChapter(widget.chapterIndex - 1)
                    : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Chapter Sebelumnya'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.chapterIndex > 0 ? Colors.grey[200] : Colors.grey[100],
                  foregroundColor: const Color(0xFF2D3142),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.chapterIndex < widget.totalChapters - 1
                    ? () => _navigateToChapter(widget.chapterIndex + 1)
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Chapter Berikutnya'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.chapterIndex < widget.totalChapters - 1 ? const Color(0xFF6C63FF) : Colors.grey[100],
                  foregroundColor: widget.chapterIndex < widget.totalChapters - 1 ? Colors.white : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection({required String title, required String content, required IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF6C63FF)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(fontSize: 15, color: Color(0xFF2D3142)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
