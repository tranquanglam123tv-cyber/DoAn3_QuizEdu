import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../provider/exam_provider.dart';
import '../../quiz/model/quiz_model.dart';

class ExamScreen extends StatefulWidget {
  final QuizModel quiz;

  const ExamScreen({super.key, required this.quiz});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _currentIndex = 0;
  bool _started = false;
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final provider = context.read<ExamProvider>();
      final theme = context.read<ThemeProvider>();
      await provider.start(widget.quiz.id);
      if (!mounted) return;
      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error!), backgroundColor: theme.danger),
        );
        context.pop();
        return;
      }
      setState(() => _started = true);
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < widget.quiz.questions.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _prev() {
    if (_currentIndex > 0) setState(() => _currentIndex--);
  }

  Future<void> _submit() async {
    final provider = context.read<ExamProvider>();
    final answered = provider.selectedAnswers.length;
    final total = widget.quiz.questions.length;

    if (answered < total) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Chưa trả lời hết', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Bạn còn ${total - answered} câu chưa trả lời. Vẫn nộp bài?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Nộp bài'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    if (!mounted) return;
    final examProvider = context.read<ExamProvider>();
    final theme = context.read<ThemeProvider>();
    final exam = await examProvider.submit();
    if (!mounted) return;
    if (exam != null) {
      context.go('/exam/${exam.id}/result');
    } else {
      final error = examProvider.error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Không thể nộp bài. Vui lòng thử lại.'),
          backgroundColor: theme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final provider = context.watch<ExamProvider>();
    final questions = widget.quiz.questions;

    if (!_started || provider.isLoading) {
      return Scaffold(
        backgroundColor: theme.background,
        body: Center(child: CircularProgressIndicator(color: theme.primaryColor)),
      );
    }

    final question = questions[_currentIndex];
    final selectedChoiceId = provider.selectedAnswers[question.id];
    final progress = (_currentIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: theme.background,
      body: Column(
        children: [
          AppTheme.glassHeader(
            context: context,
            title: '${widget.quiz.questionCount} câu • ${widget.quiz.difficulty}',
            subtitle: 'Câu ${_currentIndex + 1} / ${questions.length}',
            onBack: null,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                      ],
                    ),
                    child: Text(question.content,
                        style: TextStyle(
                            fontSize: 16, height: 1.7, color: theme.textPrimary)),
                  ),
                  const SizedBox(height: 16),
                  ...question.choices.asMap().entries.map((e) {
                    final choice = e.value;
                    final labels = ['A', 'B', 'C', 'D'];
                    final label = e.key < labels.length ? labels[e.key] : '${e.key + 1}';
                    final isSelected = selectedChoiceId == choice.id;

                    return GestureDetector(
                      onTap: () => provider.selectAnswer(question.id, choice.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.primaryColor.withValues(alpha: 0.08)
                              : theme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? theme.primaryColor : const Color(0xFFEEF0F6),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: theme.primaryColor.withValues(alpha: 0.1), blurRadius: 8)]
                              : [],
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isSelected ? theme.primaryColor : theme.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(label,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isSelected ? Colors.white : theme.textSecondary)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(choice.content,
                                    style: TextStyle(height: 1.4, color: theme.textPrimary))),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded,
                                  color: theme.primaryColor, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: theme.surface,
              boxShadow: [BoxShadow(color: const Color(0x0A000000), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _prev,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                      label: const Text('Trước'),
                    ),
                  ),
                if (_currentIndex > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _currentIndex < questions.length - 1 ? _next : _submit,
                    icon: Icon(
                      _currentIndex < questions.length - 1
                          ? Icons.arrow_forward_ios_rounded
                          : Icons.send_rounded,
                      size: 14,
                    ),
                    label: Text(
                      _currentIndex < questions.length - 1 ? 'Tiếp theo' : 'Nộp bài',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
