import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../model/document_model.dart';
import '../provider/document_provider.dart';

class DocumentScreen extends StatefulWidget {
  final int subjectId;
  final String subjectName;

  const DocumentScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<DocumentProvider>().fetchAll(widget.subjectId);
    });
  }

  Future<void> _pickAndUpload() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
        withData: true,
        allowMultiple: false,
      );
    } catch (e) {
      debugPrint('File picker error: $e');
      if (!mounted) return;
      _showUploadMessage('Không mở được hộp chọn file', false);
      return;
    }
    if (result == null || result.files.isEmpty) return;
    if (!mounted) return;

    final file = result.files.first;
    final lowerName = file.name.toLowerCase();
    final isAllowed = lowerName.endsWith('.pdf') || lowerName.endsWith('.docx');
    if (!isAllowed) {
      _showUploadMessage('Chỉ hỗ trợ file PDF hoặc DOCX', false);
      return;
    }
    if (file.size > 10 * 1024 * 1024) {
      _showUploadMessage('File vượt quá 10MB', false);
      return;
    }

    // Get bytes - works on all platforms including web
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      _showUploadMessage('Không đọc được file đã chọn', false);
      return;
    }

    final provider = context.read<DocumentProvider>();
    final ok = await provider.upload(
      widget.subjectId,
      fileName: file.name,
      bytes: bytes,
    );
    if (!mounted) return;

    _showUploadMessage(
      ok
          ? 'Tải tài liệu thành công'
          : (provider.error ?? 'Tải tài liệu thất bại. Vui lòng thử lại.'),
      ok,
    );
  }

  void _showUploadMessage(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );
  }

  Future<void> _confirmDelete(DocumentProvider provider, DocumentModel doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xoá tài liệu'),
        content: Text('Bạn có chắc muốn xoá "${doc.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final ok = await provider.delete(widget.subjectId, doc.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Đã xoá tài liệu' : (provider.error ?? 'Không thể xoá tài liệu')),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF4),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.15),
                  const Color(0xFFF0FAF4),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildAppBar(provider),
              if (provider.isUploading)
                const SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.accentLight,
                  ),
                ),
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.documents.isEmpty)
                SliverFillRemaining(
                  child: _EmptyDocuments(onUpload: _pickAndUpload),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final doc = provider.documents[i];
                        return _DocumentCard(
                          doc: doc,
                          onDelete: () => _confirmDelete(provider, doc),
                          onTap: () => context.push(
                            '/subjects/${widget.subjectId}/documents/${doc.id}/ai',
                            extra: doc,
                          ),
                        );
                      },
                      childCount: provider.documents.length,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: provider.isUploading ? null : _pickAndUpload,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
          label: Text(
            provider.isUploading ? 'Đang tải...' : 'Upload tài liệu',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(DocumentProvider provider) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7ECF9E), Color(0xFF5ABF7A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Glass overlay effects
              Positioned(
                top: 40,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.subjectName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${provider.documents.length} tài liệu',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const Spacer(),
                          // Glass button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  provider.isUploading ? Icons.hourglass_top_rounded : Icons.add_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  provider.isUploading ? 'Đang tải' : 'Thêm file',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDocuments extends StatelessWidget {
  final VoidCallback onUpload;

  const _EmptyDocuments({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.accent.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(
                Icons.upload_file_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có tài liệu nào',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload PDF hoặc DOCX để dùng AI tóm tắt, flashcard và tạo đề.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_rounded),
              label: const Text('Chọn tài liệu'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentModel doc;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.doc,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = doc.fileType.toLowerCase() == 'pdf';
    final color = isPdf ? AppColors.danger : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.15),
                        color.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      doc.fileType.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc.fileSizeText,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Xoá',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.danger,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
