import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/theme_provider.dart';
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
  int _flashcardCount = 8;

  Future<void> _summarize() async {
    setState(() => _loadingSummary = true);
    try {
      final res = await ApiClient.dio.get('/ai/summarize/${widget.documentId}');
      if (!mounted) return;
      setState(() => _summary = SummaryModel.fromJson(res.data['data']));
    } catch (e) {
      _showError('Không thể tóm tắt tài liệu', e);
    } finally {
      if (mounted) setState(() => _loadingSummary = false);
    }
  }

  Future<void> _generateFlashcards() async {
    setState(() => _loadingFlashcards = true);
    try {
      final res = await ApiClient.dio.get('/ai/flashcards/${widget.documentId}?count=$_flashcardCount');
      if (!mounted) return;
      setState(() => _flashcards = FlashcardModel.fromJson(res.data['data']));
    } catch (e) {
      _showError('Không thể tạo flashcards', e);
    } finally {
      if (mounted) setState(() => _loadingFlashcards = false);
    }
  }

  void _showError(String msg, dynamic e) {
    String detail = msg;
    if (e is Exception) {
      final str = e.toString();
      if (str.contains('"message":"')) {
        try {
          final start = str.indexOf('"message":"') + 11;
          final end = str.indexOf('"', start);
          detail = str.substring(start, end);
        } catch (_) {}
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(detail), backgroundColor: context.read<ThemeProvider>().danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: theme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: theme.gradientPrimary),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'AI Học tập',
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.documentName,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Action cards
                _GlassActionCard(
                  icon: Icons.summarize_rounded,
                  label: 'Tóm tắt tài liệu',
                  sublabel: 'AI đọc và trích xuất ý chính',
                  gradient: theme.gradientAccent,
                  isLoading: _loadingSummary,
                  onTap: _summarize,
                ),
                const SizedBox(height: 12),

                // Flashcard with count selector
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: theme.gradientWarm,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: theme.warning.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.style_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tạo Flashcards',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Sinh bộ thẻ câu hỏi - đáp án',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (_loadingFlashcards)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Count selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Số thẻ:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(width: 12),
                          ...[5, 8, 12, 16].map((count) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: GestureDetector(
                                  onTap: _loadingFlashcards ? null : () => setState(() => _flashcardCount = count),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _flashcardCount == count ? Colors.white : Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: TextStyle(
                                        color: _flashcardCount == count ? theme.warning : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _loadingFlashcards ? null : _generateFlashcards,
                          icon: _loadingFlashcards
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.auto_awesome_rounded, size: 18),
                          label: Text(_loadingFlashcards ? 'Đang tạo...' : 'Tạo $_flashcardCount flashcards'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: theme.warning,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Quiz button
                _GlassActionCard(
                  icon: Icons.quiz_rounded,
                  label: 'Tạo đề trắc nghiệm',
                  sublabel: 'Sinh bài kiểm tra tự động với 3 mức độ',
                  gradient: theme.gradientPrimary,
                  isLoading: false,
                  onTap: () => context.push('/documents/${widget.documentId}/quiz', extra: widget.documentName),
                ),

                const SizedBox(height: 24),

                // Summary result
                if (_summary != null) ...[
                  _SectionHeader(icon: Icons.notes_rounded, title: 'Tóm tắt nội dung', color: theme.accent),
                  const SizedBox(height: 12),
                  _ResultCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_summary!.overview, style: TextStyle(height: 1.7, color: theme.textPrimary, fontSize: 14)),
                        const SizedBox(height: 16),
                        Text('Ý chính:', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary)),
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
                                    decoration: BoxDecoration(color: theme.accent, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(p, style: TextStyle(height: 1.5, fontSize: 14, color: theme.textPrimary))),
                                ],
                              ),
                            ))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Flashcards result
                if (_flashcards != null) ...[
                  _SectionHeader(
                    icon: Icons.style_rounded,
                    title: 'Flashcards (${_flashcards!.flashcards.length})',
                    color: theme.warning,
                  ),
                  const SizedBox(height: 12),
                  ...(_flashcards!.flashcards.asMap().entries.map((e) => _FlashCardItem(index: e.key + 1, item: e.value))),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final LinearGradient gradient;
  final bool isLoading;
  final VoidCallback onTap;

  const _GlassActionCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.gradient,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: gradient.colors.first.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(sublabel, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            else
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.7), size: 18),
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
    final theme = context.watch<ThemeProvider>();
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary)),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Widget child;

  const _ResultCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: child,
    );
  }
}

class _FlashCardItem extends StatefulWidget {
  final int index;
  final FlashcardItem item;

  const _FlashCardItem({required this.index, required this.item});

  @override
  State<_FlashCardItem> createState() => _FlashCardItemState();
}

class _FlashCardItemState extends State<_FlashCardItem> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return GestureDetector(
      onTap: () => setState(() => _showAnswer = !_showAnswer),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _showAnswer ? theme.warning.withValues(alpha: 0.06) : theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _showAnswer ? theme.warning : const Color(0xFFEEF0F6),
            width: _showAnswer ? 1.5 : 1,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: theme.warning, borderRadius: BorderRadius.circular(8)),
                  child: Text('${widget.index}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Text('Câu hỏi', style: TextStyle(fontWeight: FontWeight.bold, color: theme.warning)),
                const Spacer(),
                Icon(_showAnswer ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: theme.textHint),
              ],
            ),
            const SizedBox(height: 10),
            Text(widget.item.question, style: TextStyle(fontSize: 14, height: 1.5, color: theme.textPrimary)),
            if (_showAnswer) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFEEF0F6)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Trả lời', style: TextStyle(fontWeight: FontWeight.bold, color: theme.success, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(widget.item.answer, style: TextStyle(fontSize: 14, height: 1.5, color: theme.textPrimary)),
            ],
          ],
        ),
      ),
    );
  }
}
