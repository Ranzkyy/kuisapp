import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizPage extends StatefulWidget {
  final String moduleTitle;

  const QuizPage({
    Key? key,
    required this.moduleTitle,
  }) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Apa itu Flutter?',
      'options': [
        'Framework UI untuk pengembangan aplikasi mobile',
        'Bahasa pemrograman baru',
        'Database management system',
        'Operating system'
      ],
      'correctAnswer': 0
    },
    {
      'question': 'Widget apa yang digunakan untuk menampilkan teks di Flutter?',
      'options': [
        'Container',
        'Text',
        'Box',
        'Label'
      ],
      'correctAnswer': 1
    },
    {
      'question': 'Apa fungsi dari setState()?',
      'options': [
        'Mengubah warna aplikasi',
        'Memperbarui tampilan UI',
        'Menyimpan data',
        'Menghapus widget'
      ],
      'correctAnswer': 1
    },
  ];

  void _checkAnswer(int selectedIndex) {
    if (selectedIndex == _questions[_currentQuestionIndex]['correctAnswer']) {
      setState(() {
        _score++;
      });
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('allQuizzesCompleted', true);

    setState(() {
      _quizCompleted = true;
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _quizCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kuis ${widget.moduleTitle}'),
        backgroundColor: const Color(0xFF6C63FF),
      ),
      body: _quizCompleted
          ? _buildQuizResult()
          : _buildQuizContent(),
    );
  }

  Widget _buildQuizContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
          ),
          const SizedBox(height: 20),
          Text(
            'Pertanyaan ${_currentQuestionIndex + 1}/${_questions.length}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _questions[_currentQuestionIndex]['question'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          ...List.generate(
            _questions[_currentQuestionIndex]['options'].length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () => _checkAnswer(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2D3142),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF6C63FF)),
                  ),
                ),
                child: Text(
                  _questions[_currentQuestionIndex]['options'][index],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizResult() {
    final percentage = (_score / _questions.length) * 100;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 100,
              color: Color(0xFF6C63FF),
            ),
            const SizedBox(height: 20),
            const Text(
              'Selamat!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Anda telah menyelesaikan kuis dengan skor:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$_score/${_questions.length}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
            Text(
              '(${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _restartQuiz,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Ulangi Kuis',
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
                minimumSize: const Size(180, 48),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
