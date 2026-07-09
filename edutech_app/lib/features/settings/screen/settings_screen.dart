import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/provider/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static void _showThemeDialog(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: themeProvider.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.palette_rounded,
                      color: themeProvider.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Đổi màu ứng dụng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Chọn màu chủ đạo cho ứng dụng',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: ThemeProvider.colorOptions.length,
                itemBuilder: (ctx, i) {
                  final option = ThemeProvider.colorOptions[i];
                  final isSelected =
                      themeProvider.primaryColor.toARGB32() ==
                      option.primary.toARGB32();
                  return GestureDetector(
                    onTap: () {
                      themeProvider.setPrimaryColor(option.primary);
                      Navigator.pop(ctx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: option.primary,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: option.primary.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 28,
                            )
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  static void _showExportDataDialog(BuildContext context) {
    final theme = context.read<ThemeProvider>();
    final selected = <String, bool>{
      'Tài liệu của tôi': true,
      'Bài kiểm tra': true,
      'Lịch sử học tập': true,
      'Thống kê': false,
    };
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.download_rounded,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Xuất dữ liệu cá nhân',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn dữ liệu bạn muốn xuất:',
                  style: TextStyle(color: theme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                _ExportOption(
                  icon: Icons.description_rounded,
                  label: 'Tài liệu của tôi',
                  selected: selected['Tài liệu của tôi']!,
                  onChanged: (v) =>
                      setState(() => selected['Tài liệu của tôi'] = v ?? false),
                ),
                _ExportOption(
                  icon: Icons.quiz_rounded,
                  label: 'Bài kiểm tra',
                  selected: selected['Bài kiểm tra']!,
                  onChanged: (v) =>
                      setState(() => selected['Bài kiểm tra'] = v ?? false),
                ),
                _ExportOption(
                  icon: Icons.history_rounded,
                  label: 'Lịch sử học tập',
                  selected: selected['Lịch sử học tập']!,
                  onChanged: (v) =>
                      setState(() => selected['Lịch sử học tập'] = v ?? false),
                ),
                _ExportOption(
                  icon: Icons.bar_chart_rounded,
                  label: 'Thống kê',
                  selected: selected['Thống kê']!,
                  onChanged: (v) =>
                      setState(() => selected['Thống kê'] = v ?? false),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: theme.primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Đã chọn ${selected.values.where((v) => v).length} mục để xuất',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await ApiClient.dio.post(
                      '/export/request',
                      data: {
                        'includeDocuments': selected['Tài liệu của tôi'],
                        'includeQuizzes': selected['Bài kiểm tra'],
                        'includeHistory': selected['Lịch sử học tập'],
                        'includeStats': selected['Thống kê'],
                      },
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Yêu cầu xuất dữ liệu đã được gửi!\nFile sẽ được gửi qua email trong 24h.',
                        ),
                        backgroundColor: theme.success,
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: $e'),
                        backgroundColor: theme.danger,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Gửi yêu cầu'),
              ),
            ],
          );
        },
      ),
    );
  }

  static void _showReminderDialog(BuildContext context) {
    final theme = context.read<ThemeProvider>();
    TimeOfDay selectedTime = TimeOfDay.now();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.notifications_active_rounded,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text('Nhắc học'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Đặt thời gian nhắc nhở hàng ngày:',
                style: TextStyle(color: theme.textSecondary),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: ctx,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedTime.format(ctx),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Bạn sẽ nhận thông báo nhắc học vào lúc này mỗi ngày.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.textSecondary, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã đặt nhắc học lúc ${selectedTime.format(context)}',
                    ),
                    backgroundColor: theme.success,
                  ),
                );
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  static void _showHelpDialog(BuildContext context) {
    final theme = context.read<ThemeProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: theme.primaryColor),
            const SizedBox(width: 8),
            const Text('Trợ giúp'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Liên hệ hỗ trợ:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _HelpOption(
              icon: Icons.email_rounded,
              label: 'Email',
              value: 'support@quizedu.com',
            ),
            _HelpOption(
              icon: Icons.phone_rounded,
              label: 'Hotline',
              value: '1900-xxxx',
            ),
            _HelpOption(
              icon: Icons.language_rounded,
              label: 'Website',
              value: 'www.quizedu.com',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đội ngũ hỗ trợ sẵn sàng giúp bạn 24/7',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
            ),
            child: const Text('Đóng', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.surface,
        foregroundColor: theme.textPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Cài đặt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: Icons.person_rounded,
            label: 'Hồ sơ cá nhân',
            onTap: () => context.go('/profile'),
          ),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.lock_reset_rounded,
            label: 'Đổi mật khẩu',
            onTap: () => context.go('/profile'),
          ),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.download_rounded,
            label: 'Xuất dữ liệu cá nhân',
            onTap: () => _showExportDataDialog(context),
          ),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.notifications_rounded,
            label: 'Nhắc học',
            onTap: () => _showReminderDialog(context),
          ),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: 'Trợ giúp',
            onTap: () => _showHelpDialog(context),
          ),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.support_agent_rounded,
            label: 'Hỗ trợ & Liên hệ',
            tileColor: Colors.teal,
            onTap: () => context.go('/support'),
          ),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.palette_rounded,
            label: 'Đổi màu ứng dụng',
            onTap: () => _showThemeDialog(context),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text(
                    'Đăng xuất',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text('Bạn có chắc muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Huỷ'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.danger,
                      ),
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              );
              if (confirm != true || !context.mounted) return;
              await context.read<AuthProvider>().logout();
              if (context.mounted) context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: theme.danger,
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Đăng xuất'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? tileColor;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.label, this.tileColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final thisTileColor = tileColor ?? theme.primaryColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: thisTileColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: thisTileColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                onTap != null
                    ? Icon(
                        Icons.chevron_right_rounded,
                        color: theme.textHint,
                        size: 22,
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final ValueChanged<bool?>? onChanged;

  const _ExportOption({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return InkWell(
      onTap: onChanged != null ? () => onChanged!(!selected) : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: theme.textPrimary),
              ),
            ),
            SizedBox(
              width: 24,
              height: 24,
              child: selected
                  ? Icon(
                      Icons.check_box_rounded,
                      size: 22,
                      color: theme.primaryColor,
                    )
                  : Icon(
                      Icons.check_box_outline_blank_rounded,
                      size: 22,
                      color: theme.textHint,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HelpOption({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: theme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: theme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
