import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../provider/exam_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final exam = context.read<ExamProvider>().currentExam;
    if (exam == null) {
      return Scaffold(
        backgroundColor: theme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.textHint),
              const SizedBox(height: 16),
              Text('Không có dữ liệu kết quả', style: TextStyle(color: theme.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Về trang chủ')),
            ],
          ),
        ),
      );
    }

    final score = exam.score;
    final isExcellent = score >= 8;
    final isPass = score >= 5;
    final gradient = isExcellent
        ? theme.gradientAccent
        : isPass
            ? const LinearGradient(
                colors: [Color(0xFFFFAA00), Color(0xFFFF8C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : theme.gradientWarm;

    final emoji = isExcellent ? '🎉' : isPass ? '👍' : '💪';
    final message = isExcellent ? 'Xuất sắc!' : isPass ? 'Khá tốt!' : 'Cố gắng hơn!';
    final correctCount = exam.correctCount;
    final total = exam.totalQuestions;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        foregroundColor: theme.textPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Kết quả bài thi', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/home'),
            icon: Icon(Icons.home_rounded, size: 18, color: theme.primaryColor),
            label: Text('Trang chủ',
                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text('$emoji $message',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$score',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold,
                              height: 1)),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text('/10',
                            style: TextStyle(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(label: 'Đúng', value: '$correctCount', icon: Icons.check_circle_rounded),
                        Container(width: 1, height: 36, color: Colors.white30),
                        _StatItem(
                            label: 'Sai',
                            value: '${total - correctCount}',
                            icon: Icons.cancel_rounded),
                        Container(width: 1, height: 36, color: Colors.white30),
                        _StatItem(label: 'Tổng', value: '$total', icon: Icons.quiz_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Detail answers
            if (exam.answers != null && exam.answers!.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.list_alt_rounded, color: theme.primaryColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text('Chi tiết từng câu',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                ],
              ),
              const SizedBox(height: 14),
              ...exam.answers!.asMap().entries.map((e) {
                final a = e.value;
                final isCorrect = a.correct;
                final borderColor = isCorrect
                    ? theme.success.withValues(alpha: 0.3)
                    : theme.danger.withValues(alpha: 0.3);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? theme.success.withValues(alpha: 0.12)
                                  : theme.danger.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                  color: isCorrect ? theme.success : theme.danger,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(isCorrect ? 'Đúng' : 'Sai',
                                    style: TextStyle(
                                        color: isCorrect ? theme.success : theme.danger,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Câu ${e.key + 1}',
                              style: TextStyle(color: theme.textSecondary, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(a.questionContent,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13, height: 1.5,
                              color: theme.textPrimary)),
                      const SizedBox(height: 10),
                      if (!isCorrect) ...[
                        _AnswerRow(
                          label: 'Bạn chọn',
                          text: a.selectedChoice,
                          color: theme.danger,
                          icon: Icons.close_rounded,
                        ),
                        const SizedBox(height: 6),
                      ],
                      _AnswerRow(
                        label: 'Đáp án',
                        text: a.correctChoice,
                        color: theme.success,
                        icon: Icons.check_rounded,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡 ', style: TextStyle(fontSize: 13)),
                            Expanded(
                              child: Text(a.explanation,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textSecondary,
                                      height: 1.5)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/subjects'),
                    icon: const Icon(Icons.book_rounded, size: 16),
                    label: const Text('Môn học'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home_rounded, size: 16),
                    label: const Text('Trang chủ'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String label;
  final String text;
  final Color color;
  final IconData icon;

  const _AnswerRow({required this.label, required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 6),
        Text('$label: ', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 12, color: theme.textPrimary, height: 1.4))),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
