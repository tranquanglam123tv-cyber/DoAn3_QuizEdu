import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_provider.dart';
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
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<DocumentProvider>().fetchAll(widget.subjectId);
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        context.read<DocumentProvider>().clearSelection();
      }
    });
  }

  void _toggleSelect(int id) {
    context.read<DocumentProvider>().toggleSelection(id);
  }

  void _selectAll() {
    context.read<DocumentProvider>().selectAll();
  }

  Future<void> _deleteSelected() async {
    final provider = context.read<DocumentProvider>();
    final selected = provider.getSelectedDocuments();
    if (selected.isEmpty) return;

    final theme = context.read<ThemeProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xoá tài liệu đã chọn'),
        content: Text('Bạn có chắc muốn xoá ${selected.length} tài liệu đã chọn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final deleted = await provider.deleteBatch(
      widget.subjectId,
      selected.map((d) => d.id).toList(),
    );

    if (!mounted) return;
    if (deleted > 0) {
      _toggleSelectionMode();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xoá $deleted tài liệu'),
        backgroundColor: theme.success,
      ),
    );
  }

  Future<void> _pickAndUpload() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
        withData: true,
        allowMultiple: true,
      );
    } catch (e) {
      debugPrint('File picker error: $e');
      if (!mounted) return;
      _showUploadMessage('Không mở được hộp chọn file', false);
      return;
    }
    if (result == null || result.files.isEmpty) return;
    if (!mounted) return;

    final provider = context.read<DocumentProvider>();
    final validFiles = result.files.where((f) {
      final lowerName = f.name.toLowerCase();
      return (lowerName.endsWith('.pdf') || lowerName.endsWith('.docx')) && f.size <= 10 * 1024 * 1024;
    }).toList();

    if (validFiles.isEmpty) {
      _showUploadMessage('Không có file hợp lệ (chỉ PDF/DOCX, <10MB)', false);
      return;
    }

    // Check for duplicates
    final fileNames = validFiles.map((f) => f.name).toList();
    final duplicates = provider.findDuplicates(fileNames);

    if (duplicates.isNotEmpty) {
      final shouldContinue = await _showDuplicateDialog(duplicates);
      if (!shouldContinue) return;
    }

    int successCount = 0;
    int failCount = 0;

    for (final file in validFiles) {
      // Skip duplicates unless user confirms
      if (duplicates.any((d) => d.fileName.toLowerCase() == file.name.toLowerCase())) {
        continue; // Already handled in dialog
      }

      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        failCount++;
        continue;
      }

      final ok = await provider.upload(
        widget.subjectId,
        fileName: file.name,
        bytes: bytes,
      );
      if (ok) {
        successCount++;
      } else {
        failCount++;
      }
    }

    if (!mounted) return;

    if (successCount > 0 && failCount == 0) {
      _showUploadMessage(
        result.files.length == 1
            ? 'Tải tài liệu thành công'
            : 'Đã tải $successCount tài liệu thành công',
        true,
      );
    } else if (successCount > 0 && failCount > 0) {
      _showUploadMessage(
        'Đã tải $successCount tài liệu, $failCount thất bại',
        false,
      );
    } else {
      _showUploadMessage(
        failCount > 0 ? 'Có $failCount file không hợp lệ' : 'Tải tài liệu thất bại',
        false,
      );
    }
  }

  Future<bool> _showDuplicateDialog(List<DocumentModel> duplicates) async {
    final theme = context.read<ThemeProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.warning),
            const SizedBox(width: 8),
            const Text('File trùng lặp'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Có ${duplicates.length} file đã tồn tại:',
                style: TextStyle(color: theme.textSecondary),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: duplicates.length,
                  itemBuilder: (ctx, i) {
                    final doc = duplicates[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.description_outlined, size: 20, color: theme.warning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              doc.fileName,
                              style: TextStyle(fontSize: 13, color: theme.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bạn có muốn bỏ qua các file trùng lặp không?',
                style: TextStyle(color: theme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tiếp tục (bỏ qua trùng)'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showUploadMessage(String message, bool success) {
    if (!mounted) return;
    final theme = context.read<ThemeProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? theme.success : theme.danger,
      ),
    );
  }

  Future<void> _confirmDelete(DocumentProvider provider, DocumentModel doc) async {
    if (!mounted) return;
    final theme = context.read<ThemeProvider>();
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
            style: ElevatedButton.styleFrom(backgroundColor: theme.danger),
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
        backgroundColor: ok ? theme.success : theme.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final provider = context.watch<DocumentProvider>();

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.accent.withValues(alpha: 0.15),
                  theme.background,
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
                SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                    color: theme.primaryColor,
                    backgroundColor: theme.accentLight,
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
                          isSelectionMode: _isSelectionMode,
                          isSelected: provider.isSelected(doc.id),
                          onToggleSelect: () => _toggleSelect(doc.id),
                          onDelete: () => _confirmDelete(provider, doc),
                          onTap: () {
                            if (_isSelectionMode) {
                              _toggleSelect(doc.id);
                            } else {
                              context.push(
                                '/subjects/${widget.subjectId}/documents/${doc.id}/ai',
                                extra: doc,
                              );
                            }
                          },
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
      floatingActionButton: _buildFab(provider),
    );
  }

  Widget _buildAppBar(DocumentProvider provider) {
    final theme = context.watch<ThemeProvider>();

    if (_isSelectionMode) {
      return SliverAppBar(
        pinned: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _toggleSelectionMode,
        ),
        title: Text('Đã chọn ${provider.selectionCount}'),
        actions: [
          TextButton(
            onPressed: provider.selectionCount < provider.documents.length ? _selectAll : null,
            child: const Text('Chọn tất cả', style: TextStyle(color: Colors.white)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: provider.hasSelection ? _deleteSelected : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.danger,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.delete_rounded),
              label: const Text('Xoá đã chọn'),
            ),
          ),
        ),
      );
    }

    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      stretch: true,
      backgroundColor: theme.primaryColor,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (provider.documents.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.checklist_rounded),
            tooltip: 'Chọn nhiều',
            onPressed: _toggleSelectionMode,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(gradient: theme.gradientPrimary),
          child: Stack(
            children: [
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
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${provider.documents.length} tài liệu',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_rounded, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                const Text('Thêm file', style: TextStyle(color: Colors.white, fontSize: 12)),
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

  Widget _buildFab(DocumentProvider provider) {
    if (_isSelectionMode) return const SizedBox.shrink();
    final theme = context.watch<ThemeProvider>();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: theme.primaryColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: provider.isUploading ? null : _pickAndUpload,
        backgroundColor: theme.primaryColor,
        icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
        label: Text(
          provider.isUploading ? 'Đang tải...' : 'Upload tài liệu',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
    final theme = context.watch<ThemeProvider>();

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
                  colors: [theme.primaryColor.withValues(alpha: 0.15), theme.accent.withValues(alpha: 0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
              ),
              child: Icon(Icons.upload_file_rounded, size: 44, color: theme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text('Chưa có tài liệu nào', style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 8),
            Text('Upload PDF hoặc DOCX để dùng AI tóm tắt, flashcard và tạo đề.', textAlign: TextAlign.center, style: TextStyle(color: theme.textSecondary, fontSize: 13)),
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
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.doc,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onToggleSelect,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isPdf = doc.fileType.toLowerCase() == 'pdf';
    final color = isPdf ? theme.danger : theme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.9),
          width: isSelected ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(color: theme.primaryColor.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, 4)),
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
                if (isSelectionMode) ...[
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggleSelect(),
                    activeColor: color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: Text(doc.fileType.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.fileName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(doc.fileSizeText, style: TextStyle(color: theme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                if (!isSelectionMode) ...[
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                      tooltip: 'Xoá',
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline_rounded, color: theme.danger),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: theme.textHint),
                ] else ...[
                  Icon(Icons.chevron_right_rounded, color: theme.textHint),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
