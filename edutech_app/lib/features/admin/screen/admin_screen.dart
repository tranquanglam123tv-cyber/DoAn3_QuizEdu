import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edutech_app/core/api/api_client.dart';
import 'package:edutech_app/core/theme/theme_provider.dart';
import 'package:edutech_app/features/auth/provider/auth_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;
  List<dynamic> _users = [];
  List<dynamic> _contacts = [];
  List<dynamic> _exportRequests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final usersRes = await ApiClient.dio.get('/admin/users');
      final contactsRes = await ApiClient.dio.get('/admin/contacts');
      final exportRes = await ApiClient.dio.get('/admin/export-requests');
      if (mounted) {
        setState(() {
          _users = usersRes.data['data'] ?? [];
          _contacts = contactsRes.data['data'] ?? [];
          _exportRequests = exportRes.data['data'] ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final isAdmin = (auth.currentUser?.role ?? '').toUpperCase() == 'ADMIN';

    if (!isAdmin) {
      return Scaffold(
        backgroundColor: theme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings_rounded, size: 80, color: theme.danger),
              const SizedBox(height: 20),
              Text('Truy cập bị từ chối', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textPrimary)),
              const SizedBox(height: 8),
              Text('Bạn không có quyền truy cập trang Admin', style: TextStyle(color: theme.textSecondary)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings_rounded, size: 28),
            const SizedBox(width: 12),
            const Text('Bảng Quản Trị', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                  backgroundColor: theme.surface,
                  indicatorColor: theme.primaryColor.withValues(alpha: 0.2),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined, color: theme.primaryColor),
                      selectedIcon: Icon(Icons.dashboard_rounded, color: theme.primaryColor),
                      label: Text('Tổng quan', style: TextStyle(color: theme.primaryColor)),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outline_rounded, color: theme.primaryColor),
                      selectedIcon: Icon(Icons.people_rounded, color: theme.primaryColor),
                      label: Text('Người dùng', style: TextStyle(color: theme.primaryColor)),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.support_agent_outlined, color: theme.primaryColor),
                      selectedIcon: Icon(Icons.support_agent_rounded, color: theme.primaryColor),
                      label: Text('Hỗ trợ', style: TextStyle(color: theme.primaryColor)),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.download_outlined, color: theme.primaryColor),
                      selectedIcon: Icon(Icons.download_rounded, color: theme.primaryColor),
                      label: Text('Yêu cầu xuất', style: TextStyle(color: theme.primaryColor)),
                    ),
                  ],
                ),
                VerticalDivider(width: 1, thickness: 1, color: theme.textHint.withValues(alpha: 0.2)),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardContent(users: _users, contacts: _contacts, exportRequests: _exportRequests);
      case 1:
        return _UsersContent(users: _users);
      case 2:
        return _ContactsContent(contacts: _contacts, onRefresh: _loadData);
      case 3:
        return _ExportRequestsContent(requests: _exportRequests, onRefresh: _loadData);
      default:
        return _DashboardContent(users: _users, contacts: _contacts, exportRequests: _exportRequests);
    }
  }
}

class _DashboardContent extends StatelessWidget {
  final List<dynamic> users;
  final List<dynamic> contacts;
  final List<dynamic> exportRequests;
  const _DashboardContent({required this.users, required this.contacts, required this.exportRequests});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final pendingContacts = contacts.where((c) => c['status'] == 'PENDING').length;
    final pendingExports = exportRequests.where((r) => r['status'] == 'PENDING').length;
    final totalExams = users.fold<int>(0, (sum, u) => sum + (u['totalExams'] as int? ?? 0));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng quan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textPrimary)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.people_rounded, label: 'Người dùng', value: '${users.length}', color: theme.primaryColor)),
              const SizedBox(width: 16),
              Expanded(child: _StatCard(icon: Icons.quiz_rounded, label: 'Bài thi', value: '$totalExams', color: theme.success)),
              const SizedBox(width: 16),
              Expanded(child: _StatCard(icon: Icons.mail_rounded, label: 'Yêu cầu xuất', value: '${exportRequests.length}', color: theme.accent)),
            ],
          ),
          const SizedBox(height: 24),
          if (pendingContacts > 0 || pendingExports > 0)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.warning, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_rounded, size: 24, color: theme.warning),
                      const SizedBox(width: 12),
                      Text('Yêu cầu chờ xử lý', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (pendingContacts > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('• $pendingContacts yêu cầu hỗ trợ chưa phản hồi', style: TextStyle(color: theme.textSecondary)),
                    ),
                  if (pendingExports > 0)
                    Text('• $pendingExports yêu cầu xuất dữ liệu chưa xử lý', style: TextStyle(color: theme.textSecondary)),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.success, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 40, color: theme.success),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('Tất cả yêu cầu đã được xử lý!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textPrimary)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: theme.textSecondary)),
        ],
      ),
    );
  }
}

class _UsersContent extends StatelessWidget {
  final List<dynamic> users;
  const _UsersContent({required this.users});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Danh sách người dùng (${users.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textPrimary)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: users.length,
            itemBuilder: (ctx, i) {
              final user = users[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.textHint.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                      child: Text(user['fullName']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['fullName'] ?? 'N/A', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary)),
                          const SizedBox(height: 4),
                          Text(user['email'] ?? '', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${user['totalExams'] ?? 0} bài thi', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                        const SizedBox(height: 4),
                        Text('TB: ${user['averageScore'] ?? 0.0}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ContactsContent extends StatelessWidget {
  final List<dynamic> contacts;
  final VoidCallback onRefresh;
  const _ContactsContent({required this.contacts, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Yêu cầu hỗ trợ (${contacts.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textPrimary)),
        ),
        Expanded(
          child: contacts.isEmpty
              ? Center(child: Text('Chưa có yêu cầu nào', style: TextStyle(color: theme.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: contacts.length,
                  itemBuilder: (ctx, i) {
                    final contact = contacts[i];
                    final isPending = contact['status'] == 'PENDING';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isPending ? theme.warning.withValues(alpha: 0.05) : theme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isPending ? theme.warning : theme.textHint.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPending ? theme.warning : theme.success,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(isPending ? 'Chờ xử lý' : 'Đã phản hồi',
                                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              const Spacer(),
                              Text(contact['createdAt']?.toString().substring(0, 10) ?? '', style: TextStyle(fontSize: 12, color: theme.textHint)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(contact['subject'] ?? 'N/A', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary)),
                          const SizedBox(height: 8),
                          Text(contact['message'] ?? '', style: TextStyle(fontSize: 13, color: theme.textSecondary), maxLines: 3, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 16, color: theme.textHint),
                              const SizedBox(width: 4),
                              Text(contact['userName'] ?? '', style: TextStyle(fontSize: 12, color: theme.textHint)),
                              const SizedBox(width: 16),
                              Icon(Icons.email_outlined, size: 16, color: theme.textHint),
                              const SizedBox(width: 4),
                              Text(contact['email'] ?? '', style: TextStyle(fontSize: 12, color: theme.textHint)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ExportRequestsContent extends StatelessWidget {
  final List<dynamic> requests;
  final VoidCallback onRefresh;
  const _ExportRequestsContent({required this.requests, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final pending = requests.where((r) => r['status'] == 'PENDING').toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Text('Yêu cầu xuất dữ liệu (${requests.length})', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textPrimary)),
              ),
              if (pending.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await ApiClient.dio.post('/admin/export-requests/send-all-pending');
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã gửi ${pending.length} yêu cầu xuất!'), backgroundColor: theme.success),
                      );
                      onRefresh();
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e'), backgroundColor: theme.danger),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: theme.accent),
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  label: Text('Gửi hàng loạt (${pending.length})', style: const TextStyle(color: Colors.white)),
                ),
            ],
          ),
        ),
        Expanded(
          child: requests.isEmpty
              ? Center(child: Text('Chưa có yêu cầu xuất nào', style: TextStyle(color: theme.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: requests.length,
                  itemBuilder: (ctx, i) {
                    final req = requests[i];
                    final isPending = req['status'] == 'PENDING';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isPending ? theme.accent.withValues(alpha: 0.05) : theme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isPending ? theme.accent : theme.textHint.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPending ? theme.accent : theme.success,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(isPending ? 'Chờ xử lý' : 'Đã gửi',
                                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              const Spacer(),
                              Text(req['createdAt']?.toString().substring(0, 10) ?? '', 
                                  style: TextStyle(fontSize: 12, color: theme.textHint)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: theme.accent.withValues(alpha: 0.1),
                                child: Text(req['userName']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                                    style: TextStyle(color: theme.accent, fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(req['userName'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary)),
                                  Text(req['email'] ?? '', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (req['includeDocuments'] == true)
                                _Chip(label: 'Tài liệu', theme: theme),
                              if (req['includeQuizzes'] == true)
                                _Chip(label: 'Bài kiểm tra', theme: theme),
                              if (req['includeHistory'] == true)
                                _Chip(label: 'Lịch sử', theme: theme),
                              if (req['includeStats'] == true)
                                _Chip(label: 'Thống kê', theme: theme),
                            ],
                          ),
                          if (isPending) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      await ApiClient.dio.post('/admin/export-requests/${req['id']}/send-email');
                                      if (!ctx.mounted) return;
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(content: Text('Đã gửi email cho ${req['userName']}'), backgroundColor: theme.success),
                                      );
                                      onRefresh();
                                    } catch (e) {
                                      if (!ctx.mounted) return;
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(content: Text('Lỗi: $e'), backgroundColor: theme.danger),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: theme.accent, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                                  icon: const Icon(Icons.email, color: Colors.white, size: 16),
                                  label: const Text('Gửi Email', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final ThemeProvider theme;
  const _Chip({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: theme.accent)),
    );
  }
}
