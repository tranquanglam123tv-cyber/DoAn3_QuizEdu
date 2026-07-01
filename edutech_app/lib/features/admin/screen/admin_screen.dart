import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/provider/auth_provider.dart';
import '../model/admin_model.dart';
import '../provider/admin_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      if (!mounted) return;
      final p = context.read<AdminProvider>();
      p.fetchDashboard();
      p.fetchUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final auth = context.watch<AuthProvider>();
    final adminName = auth.currentUser?.fullName ?? 'Admin';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            title: const Text(
              'Admin Panel',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                tooltip: 'Đăng xuất',
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Đăng xuất'),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true || !context.mounted) return;

                  final authProvider = context.read<AuthProvider>();
                  final router = GoRouter.of(context);
                  await authProvider.logout();
                  router.go('/login');
                },
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xin chào, $adminName',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const Text(
                                'Hệ thống quản trị',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.pets_rounded,
                          color: Colors.white70,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (provider.isLoadingDashboard)
                      const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    else if (provider.dashboard != null)
                      _DashboardRow(dashboard: provider.dashboard!),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.people_rounded, size: 18),
                  text: 'Người dùng',
                ),
                Tab(
                  icon: Icon(Icons.insert_chart_rounded, size: 18),
                  text: 'Thống kê',
                ),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            _UsersTab(),
            _StatsTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard row ────────────────────────────────────────────────────────────

class _DashboardRow extends StatelessWidget {
  final AdminDashboardModel dashboard;
  const _DashboardRow({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _MiniStat(
          label: 'Users',
          value: '${dashboard.totalUsers}',
          icon: Icons.people_rounded,
        ),
        _MiniStat(
          label: 'Môn học',
          value: '${dashboard.totalSubjects}',
          icon: Icons.book_rounded,
        ),
        _MiniStat(
          label: 'Tài liệu',
          value: '${dashboard.totalDocuments}',
          icon: Icons.description_rounded,
        ),
        _MiniStat(
          label: 'Quiz',
          value: '${dashboard.totalQuizzes}',
          icon: Icons.quiz_rounded,
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Users Tab ────────────────────────────────────────────────────────────────

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _filter = 'ALL'; // ALL | ACTIVE | LOCKED

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AdminUserModel> get _filtered {
    final provider = context.read<AdminProvider>();
    var list = provider.users;
    if (_filter == 'ACTIVE') list = list.where((u) => !u.locked).toList();
    if (_filter == 'LOCKED') list = list.where((u) => u.locked).toList();
    if (_query.isNotEmpty) {
      list = list
          .where(
            (u) =>
                u.fullName.toLowerCase().contains(_query.toLowerCase()) ||
                u.email.toLowerCase().contains(_query.toLowerCase()),
          )
          .toList();
    }
    return list;
  }

  Future<void> _toggleLock(AdminUserModel user) async {
    final action = user.locked ? 'mở khóa' : 'khóa';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${user.locked ? 'Mở khóa' : 'Khóa'} tài khoản',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Bạn có chắc muốn $action tài khoản "${user.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: user.locked
                  ? AppColors.success
                  : AppColors.danger,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(user.locked ? 'Mở khóa' : 'Khóa'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final p = context.read<AdminProvider>();
    final ok = user.locked
        ? await p.unlockUser(user.id)
        : await p.lockUser(user.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? '✅ Đã $action tài khoản' : (p.error ?? 'Có lỗi xảy ra'),
          ),
          backgroundColor: ok ? AppColors.success : AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = _filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm tên, email...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _FilterChip(
                label: 'Tất cả',
                value: 'ALL',
                selected: _filter,
                onTap: (v) => setState(() => _filter = v),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Hoạt động',
                value: 'ACTIVE',
                selected: _filter,
                onTap: (v) => setState(() => _filter = v),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Bị khóa',
                value: 'LOCKED',
                selected: _filter,
                onTap: (v) => setState(() => _filter = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: context.watch<AdminProvider>().isLoadingUsers
              ? const Center(child: CircularProgressIndicator())
              : users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 60,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Không tìm thấy người dùng',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => context.read<AdminProvider>().fetchUsers(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: users.length,
                        itemBuilder: (_, i) => _UserCard(
                          user: users[i],
                          onToggleLock: () => _toggleLock(users[i]),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFDDE2EE),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback onToggleLock;

  const _UserCard({required this.user, required this.onToggleLock});

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == 'ADMIN';
    final initials = user.fullName.isNotEmpty
        ? user.fullName
              .trim()
              .split(' ')
              .map((w) => w[0])
              .take(2)
              .join()
              .toUpperCase()
        : 'U';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: user.locked
            ? Border.all(color: AppColors.danger.withValues(alpha: 0.3))
            : Border.all(color: const Color(0xFFE8F0EB)),
        boxShadow: [
          BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.06), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isAdmin ? AppColors.warning : AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? AppColors.warning.withValues(alpha: 0.12)
                            : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAdmin ? 'Admin' : 'User',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isAdmin ? AppColors.warning : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.locked) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_rounded,
                        color: AppColors.danger,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Tài khoản đã bị khóa',
                        style: TextStyle(color: AppColors.danger, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!isAdmin)
            GestureDetector(
              onTap: onToggleLock,
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: user.locked
                      ? AppColors.success.withValues(alpha: 0.08)
                      : AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  user.locked ? Icons.lock_open_rounded : Icons.lock_rounded,
                  color: user.locked ? AppColors.success : AppColors.danger,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Stats Tab ────────────────────────────────────────────────────────────────

class _StatsTab extends StatelessWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final d = provider.dashboard;
    if (provider.isLoadingDashboard) {
      return const Center(child: CircularProgressIndicator());
    }
    if (d == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.insights_rounded,
              size: 60,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 12),
            const Text(
              'Không có dữ liệu',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<AdminProvider>().fetchDashboard(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final stats = [
      _StatData(
        'Tổng người dùng',
        d.totalUsers,
        Icons.people_rounded,
        AppColors.primary,
      ),
      _StatData(
        'Tổng môn học',
        d.totalSubjects,
        Icons.book_rounded,
        AppColors.accent,
      ),
      _StatData(
        'Tổng tài liệu',
        d.totalDocuments,
        Icons.description_rounded,
        AppColors.warning,
      ),
      _StatData(
        'Tổng đề Quiz',
        d.totalQuizzes,
        Icons.quiz_rounded,
        AppColors.success,
      ),
      _StatData(
        'Tổng bài thi',
        d.totalExams,
        Icons.assignment_turned_in_rounded,
        AppColors.danger,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: const [
            Icon(
              Icons.pets_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Tổng quan hệ thống',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: stats.map((s) => _StatCard(data: s)).toList(),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8F0EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.pets_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Tỉ lệ hoạt động',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _RatioBar(
                label: 'Tài liệu / Môn học',
                value: d.totalSubjects > 0
                    ? d.totalDocuments / (d.totalSubjects * 5)
                    : 0,
                color: AppColors.accent,
                detail: '${d.totalDocuments} tài liệu, ${d.totalSubjects} môn',
              ),
              const SizedBox(height: 12),
              _RatioBar(
                label: 'Quiz / Tài liệu',
                value: d.totalDocuments > 0
                    ? d.totalQuizzes / (d.totalDocuments * 3)
                    : 0,
                color: AppColors.warning,
                detail: '${d.totalQuizzes} đề, ${d.totalDocuments} tài liệu',
              ),
              const SizedBox(height: 12),
              _RatioBar(
                label: 'Bài thi / Quiz',
                value: d.totalQuizzes > 0
                    ? d.totalExams / (d.totalQuizzes * 5)
                    : 0,
                color: AppColors.primary,
                detail: '${d.totalExams} bài thi, ${d.totalQuizzes} đề',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: Colors.white, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data.value}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                data.label,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatioBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String detail;

  const _RatioBar({
    required this.label,
    required this.value,
    required this.color,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${(clamped * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: clamped,
            backgroundColor: AppColors.background,
            color: color,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
