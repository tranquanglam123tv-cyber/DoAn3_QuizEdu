import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../provider/quiz_provider.dart';

class QuizConfigScreen extends StatefulWidget {
  final int documentId;
  final String documentName;

  const QuizConfigScreen({
    super.key,
    required this.documentId,
    required this.documentName,
  });

  @override
  State<QuizConfigScreen> createState() => _QuizConfigScreenState();
}

class _QuizConfigScreenState extends State<QuizConfigScreen> {
  int _questionCount = 10;
  String _difficulty = 'MEDIUM';

  List<Map<String, dynamic>> _getDifficulties(ThemeProvider theme) => [
    {'value': 'EASY', 'label': 'Dễ', 'sub': 'Kiến thức cơ bản', 'color': theme.success},
    {'value': 'MEDIUM', 'label': 'Trung bình', 'sub': 'Hiểu và áp dụng', 'color': theme.warning},
    {'value': 'HARD', 'label': 'Khó', 'sub': 'Phân tích và tổng hợp', 'color': theme.danger},
  ];

  final _counts = [5, 10, 20, 40];

  void _onDifficultySelected(String value) {
    setState(() => _difficulty = value);
  }

  void _onCountSelected(int count) {
    setState(() => _questionCount = count);
  }

  Future<void> _generate() async {
    final provider = context.read<QuizProvider>();
    final router = GoRouter.of(context);
    final theme = context.read<ThemeProvider>();
    final quiz = await provider.generate(widget.documentId, _questionCount, _difficulty);
    if (!mounted) return;
    if (quiz != null) {
      router.push('/quiz/${quiz.id}/preview', extra: quiz);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Không thể tạo đề. Vui lòng thử lại.'),
          backgroundColor: theme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final provider = context.watch<QuizProvider>();
    final difficulties = _getDifficulties(theme);

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
        title: const Text('Tạo đề trắc nghiệm', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Document info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: theme.gradientPrimary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.description_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(widget.documentName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Question count
                Text('Số câu hỏi',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                const SizedBox(height: 4),
                Text('Chọn số lượng câu hỏi cho đề thi',
                    style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 8 * 3) / 4;
                    return Row(
                      children: _counts.map((c) {
                        final selected = _questionCount == c;
                        final isLocked = c == 20 || c == 40;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _onCountSelected(c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              constraints: BoxConstraints(minWidth: itemWidth),
                              decoration: BoxDecoration(
                                color: selected ? theme.primaryColor : theme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected ? theme.primaryColor : const Color(0xFFEEF0F6),
                                  width: selected ? 2 : 1,
                                ),
                                boxShadow: selected
                                    ? [BoxShadow(color: theme.primaryColor.withValues(alpha: 0.25), blurRadius: 8)]
                                    : [],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Center(
                                    child: Text('$c',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: selected ? Colors.white : theme.textSecondary)),
                                  ),
                                  if (isLocked)
                                    Positioned(
                                      right: 4,
                                      top: 2,
                                      child: Icon(Icons.lock_rounded, size: 12, color: theme.textHint),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Difficulty
                Text('Độ khó',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold, color: theme.textPrimary)),
                const SizedBox(height: 4),
                Text('Chọn mức độ phù hợp với trình độ của bạn',
                    style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                const SizedBox(height: 14),
                Column(
                  children: difficulties.map((d) {
                    final selected = _difficulty == d['value'];
                    final color = d['color'] as Color;
                    final isPremium = d['premium'] == true;
                    return GestureDetector(
                      onTap: () => _onDifficultySelected(d['value'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selected ? color.withValues(alpha: 0.08) : theme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? color : const Color(0xFFEEF0F6),
                            width: selected ? 2 : 1,
                          ),
                          boxShadow: selected
                              ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 8)]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                d['value'] == 'EASY'
                                    ? Icons.sentiment_satisfied_alt_rounded
                                    : d['value'] == 'MEDIUM'
                                        ? Icons.sentiment_neutral_rounded
                                        : Icons.sentiment_very_dissatisfied_rounded,
                                color: color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(d['label'] as String,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: selected ? color : theme.textPrimary)),
                                      if (isPremium) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: theme.warning.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.workspace_premium_rounded, size: 10, color: theme.warning),
                                              const SizedBox(width: 2),
                                              Text('Premium', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.warning)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(d['sub'] as String,
                                      style: TextStyle(
                                          fontSize: 12, color: theme.textSecondary)),
                                ],
                              ),
                            ),
                            if (isPremium)
                              Icon(Icons.lock_rounded, color: theme.textHint, size: 20)
                            else if (selected)
                              Icon(Icons.check_circle_rounded, color: color, size: 22)
                            else
                              Icon(Icons.radio_button_unchecked_rounded,
                                  color: theme.textHint, size: 22),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: provider.isGenerating ? null : _generate,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                    label: const Text('Tạo đề ngay',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          if (provider.isGenerating)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: theme.gradientPrimary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 20),
                      Text('AI đang tạo đề...',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: theme.textPrimary)),
                      const SizedBox(height: 8),
                      Text('Có thể mất 30–60 giây',
                          style: TextStyle(color: theme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        color: theme.primaryColor,
                        backgroundColor: theme.background,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
