import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../model/ai_model.dart';

class AIScreen extends StatefulWidget {
  final int documentId;
  final String documentName;

  const AIScreen({
    super.key,
    required this.documentId,
    required this.documentName,
  });

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  SummaryModel? _summary;
  FlashcardModel? _flashcards;
  bool _loadingSummary = false;
  bool _loadingFlashcards = false;

  Future<void> _summarize() async {
    setState(() => _loadingSummary = true);
    try {
      final res = await ApiClient.dio.get('/ai/summarize/${widget.documentId}');
      setState(() => _summary = SummaryModel.fromJson(res.data['data']));
    } catch (e) {
      var message = 'Không thể tóm tắt tài liệu';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      setState(() => _loadingSummary = false);
    }
  }

  Future<void> _flashcard() async {
    setState(() => _loadingFlashcards = true);
    try {
      final res = await ApiClient.dio.get('/ai/flashcards/${widget.documentId}');
      setState(() => _flashcards = FlashcardModel.fromJson(res.data['data']));
    } catch (e) {
      var message = 'Không thể tạo flashcard';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      setState(() => _loadingFlashcards = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('AI Học tập', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
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
                    child: const Icon(Icons.description_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(widget.documentName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action buttons
            const Text('Chọn tính năng AI',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.summarize_rounded,
                    label: 'Tóm tắt',
                    gradient: AppColors.gradientAccent,
                    isLoading: _loadingSummary,
                    onTap: _summarize,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.style_rounded,
                    label: 'Flashcards',
                    gradient: AppColors.gradientWarm,
                    isLoading: _loadingFlashcards,
                    onTap: _flashcard,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.quiz_rounded,
              label: 'Tạo đề trắc nghiệm',
              gradient: AppColors.gradientPrimary,
              isLoading: false,
              onTap: () => context.push('/documents/${widget.documentId}/quiz',
                  extra: widget.documentName),
              fullWidth: true,
            ),

            // Summary result
            if (_summary != null) ...[
              const SizedBox(height: 28),
              _SectionHeader(icon: Icons.notes_rounded, title: 'Tóm tắt nội dung', color: AppColors.accent),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_summary!.overview,
                        style: const TextStyle(height: 1.7, color: AppColors.textPrimary, fontSize: 14)),
                    const SizedBox(height: 16),
                    const Text('Ý chính:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    ...(_summary!.keyPoints.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                    color: AppColors.accent, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Text(p,
                                      style: const TextStyle(
                                          height: 1.5, fontSize: 14, color: AppColors.textPrimary))),
                            ],
                          ),
                        ))),
                  ],
                ),
              ),
            ],

            // Flashcards result
            if (_flashcards != null) ...[
              const SizedBox(height: 28),
              _SectionHeader(
                  icon: Icons.style_rounded,
                  title: 'Flashcards (${_flashcards!.flashcards.length})',
                  color: AppColors.warning),
              const SizedBox(height: 12),
              ...(_flashcards!.flashcards.asMap().entries
                  .map((e) => _FlashCard(index: e.key + 1, item: e.value))),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final bool isLoading;
  final VoidCallback onTap;
  final bool fullWidth;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.isLoading,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            else
              Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _FlashCard extends StatefulWidget {
  final int index;
  final FlashcardItem item;

  const _FlashCard({required this.index, required this.item});

  @override
  State<_FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<_FlashCard> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showAnswer = !_showAnswer),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _showAnswer ? AppColors.warning.withValues(alpha: 0.06) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _showAnswer ? AppColors.warning : const Color(0xFFEEF0F6),
            width: _showAnswer ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${widget.index}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                const Text('Câu hỏi',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning)),
                const Spacer(),
                Icon(
                  _showAnswer ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textHint,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(widget.item.question,
                style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary)),
            if (_showAnswer) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFEEF0F6)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Trả lời',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                            fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(widget.item.answer,
                  style: const TextStyle(
                      fontSize: 14, height: 1.5, color: AppColors.textPrimary)),
            ],
          ],
        ),
      ),
    );
  }
}
