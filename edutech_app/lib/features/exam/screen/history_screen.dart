import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../model/exam_model.dart';
import '../provider/exam_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<ExamProvider>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final provider = context.watch<ExamProvider>();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        foregroundColor: theme.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Lịch sử bài thi', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.fetchHistory(),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.history.isEmpty
              ? _EmptyState(theme: theme)
              : RefreshIndicator(
                  onRefresh: provider.fetchHistory,
                  color: theme.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.history.length,
                    itemBuilder: (ctx, i) => _HistoryCard(
                      exam: provider.history[i],
                      theme: theme,
                      onTap: () => _showDetail(ctx, provider.history[i], theme),
                    ),
                  ),
                ),
    );
  }

  void _showDetail(BuildContext context, ExamModel exam, ThemeProvider theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReviewSheet(exam: exam, theme: theme),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeProvider theme;
  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: theme.textHint.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch sử bài thi',
            style: TextStyle(fontSize: 16, color: theme.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Làm bài thi để xem lại kết quả tại đây',
            style: TextStyle(fontSize: 13, color: theme.textHint),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ExamModel exam;
  final ThemeProvider theme;
  final VoidCallback onTap;

  const _HistoryCard({required this.exam, required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPassed = exam.score >= 5;
    final scoreColor = isPassed ? theme.success : theme.danger;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: scoreColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.quizName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _Tag(label: exam.difficultyLabel, color: theme.primaryColor),
                          const SizedBox(width: 8),
                          _Tag(
                            label: exam.status == 'SUBMITTED' ? 'Đã nộp' : 'Đang thi',
                            color: exam.status == 'SUBMITTED' ? theme.success : theme.warning,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      exam.score.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      '/10',
                      style: TextStyle(fontSize: 12, color: theme.textHint),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: theme.textHint.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.quiz_rounded,
                  label: 'Câu hỏi',
                  value: '${exam.totalQuestions}',
                  theme: theme,
                ),
                _StatItem(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Đúng',
                  value: '${exam.correctCount}',
                  theme: theme,
                  color: theme.success,
                ),
                _StatItem(
                  icon: Icons.cancel_outlined,
                  label: 'Sai',
                  value: '${exam.totalQuestions - exam.correctCount}',
                  theme: theme,
                  color: theme.danger,
                ),
                Icon(Icons.chevron_right_rounded, color: theme.textHint, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            if (exam.submittedAt != null)
              Text(
                _formatDate(exam.submittedAt!),
                style: TextStyle(fontSize: 11, color: theme.textHint),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return 'Vừa xong';
      if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
      if (diff.inDays < 1) return '${diff.inHours} giờ trước';
      if (diff.inDays < 7) return '${diff.inDays} ngày trước';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeProvider theme;
  final Color? color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? theme.textHint),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: TextStyle(fontSize: 12, color: theme.textSecondary),
        ),
      ],
    );
  }
}

class _ReviewSheet extends StatelessWidget {
  final ExamModel exam;
  final ThemeProvider theme;

  const _ReviewSheet({required this.exam, required this.theme});

  @override
  Widget build(BuildContext context) {
    final answers = exam.answers ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.textHint.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chi tiết bài thi',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exam.quizName,
                          style: TextStyle(fontSize: 13, color: theme.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (exam.score >= 5 ? theme.success : theme.danger).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${exam.score.toStringAsFixed(1)} điểm',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: exam.score >= 5 ? theme.success : theme.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: theme.textHint.withValues(alpha: 0.15), height: 1),
            Expanded(
              child: answers.isEmpty
                  ? Center(
                      child: Text(
                        'Không có dữ liệu câu trả lời',
                        style: TextStyle(color: theme.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: answers.length,
                      itemBuilder: (ctx, i) => _AnswerCard(
                        index: i + 1,
                        answer: answers[i],
                        theme: theme,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final int index;
  final AnswerResultModel answer;
  final ThemeProvider theme;

  const _AnswerCard({required this.index, required this.answer, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isCorrect = answer.correct;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? theme.success.withValues(alpha: 0.3)
              : theme.danger.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isCorrect
                  ? theme.success.withValues(alpha: 0.08)
                  : theme.danger.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCorrect ? theme.success : theme.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isCorrect ? Icons.check_rounded : Icons.close_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Câu $index',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? theme.success : theme.danger,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? theme.success.withValues(alpha: 0.15)
                        : theme.danger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isCorrect ? 'Đúng' : 'Sai',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? theme.success : theme.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  answer.questionContent,
                  style: TextStyle(fontSize: 14, color: theme.textPrimary, height: 1.5),
                ),
                const SizedBox(height: 16),
                _ChoiceRow(
                  label: 'Đáp án của bạn',
                  value: answer.selectedChoice,
                  color: isCorrect ? theme.success : theme.danger,
                  icon: isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  theme: theme,
                ),
                if (!isCorrect) ...[
                  const SizedBox(height: 10),
                  _ChoiceRow(
                    label: 'Đáp án đúng',
                    value: answer.correctChoice,
                    color: theme.success,
                    icon: Icons.check_circle_rounded,
                    theme: theme,
                  ),
                ],
                if (answer.explanation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, size: 16, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            answer.explanation,
                            style: TextStyle(fontSize: 13, color: theme.textSecondary, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final ThemeProvider theme;

  const _ChoiceRow({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: theme.textHint)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
