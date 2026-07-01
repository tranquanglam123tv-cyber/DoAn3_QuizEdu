import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
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

  int get _secondsPerQuestion => 60;

  void _startTimer() {
    _secondsLeft = widget.quiz.questions.length * _secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft <= 0) {
        _timer?.cancel();
        _submit();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _timerText {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_secondsLeft <= 60) return AppColors.danger;
    if (_secondsLeft <= 120) return AppColors.warning;
    return AppColors.success;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final provider = context.read<ExamProvider>();
      await provider.start(widget.quiz.id);
      if (!mounted) return;
      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error!), backgroundColor: AppColors.danger),
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
    final exam = await context.read<ExamProvider>().submit();
    if (!mounted) return;
    if (exam != null) {
      context.go('/exam/${exam.id}/result');
    } else {
      final error = context.read<ExamProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Không thể nộp bài. Vui lòng thử lại.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExamProvider>();
    final questions = widget.quiz.questions;

    if (!_started || provider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final question = questions[_currentIndex];
    final selectedChoiceId = provider.selectedAnswers[question.id];
    final progress = (_currentIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.quiz.questionCount} câu • ${widget.quiz.difficulty}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text('Câu ${_currentIndex + 1} / ${questions.length}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          // Timer
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _timerColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_rounded, size: 14, color: _timerColor),
                const SizedBox(width: 4),
                Text(
                  _timerText,
                  style: TextStyle(
                    color: _timerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.send_rounded, size: 16, color: AppColors.primary),
            label: const Text('Nộp bài',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.background,
                    color: AppColors.primary,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${provider.selectedAnswers.length}/${questions.length} đã trả lời',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    // Question dots navigator
                    Flexible(
                      child: SizedBox(
                        height: 26,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: questions.length,
                          itemBuilder: (ctx, i) => GestureDetector(
                            onTap: () => setState(() => _currentIndex = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 26,
                              height: 26,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == _currentIndex
                                    ? AppColors.primary
                                    : provider.selectedAnswers.containsKey(questions[i].id)
                                        ? AppColors.success
                                        : AppColors.background,
                                border: Border.all(
                                  color: i == _currentIndex
                                      ? AppColors.primary
                                      : provider.selectedAnswers.containsKey(questions[i].id)
                                          ? AppColors.success
                                          : const Color(0xFFDDE2EE),
                                ),
                              ),
                              child: Center(
                                child: Text('${i + 1}',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: i == _currentIndex ||
                                                provider.selectedAnswers.containsKey(questions[i].id)
                                            ? Colors.white
                                            : AppColors.textHint)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Question + choices
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
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                      ],
                    ),
                    child: Text(question.content,
                        style: const TextStyle(
                            fontSize: 16, height: 1.7, color: AppColors.textPrimary)),
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
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : const Color(0xFFEEF0F6),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 8)]
                              : [],
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(label,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isSelected ? Colors.white : AppColors.textSecondary)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(choice.content,
                                    style: const TextStyle(height: 1.4, color: AppColors.textPrimary))),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.primary, size: 20),
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
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -2))],
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
