import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../features/auth/provider/auth_provider.dart';
import '../model/dashboard_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardModel? _data;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final res = await ApiClient.dio.get('/dashboard/student');
      if (mounted) {
        setState(() {
          _data = DashboardModel.fromJson(res.data['data']);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final name = auth.currentUser?.fullName ?? '';
    final firstName = name.trim().split(' ').last;

    return Scaffold(
      backgroundColor: theme.background,
      body: RefreshIndicator(
        onRefresh: _load,
        color: theme.primaryColor,
        child: CustomScrollView(
          slivers: [
            _buildHeader(firstName),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 56, color: theme.textHint),
                      const SizedBox(height: 12),
                      Text('Không thể tải dữ liệu', style: TextStyle(color: theme.textSecondary, fontSize: 15)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _GlassCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Điểm trung bình',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      (_data?.averageScore ?? 0).toStringAsFixed(
                                          (_data?.averageScore ?? 0).truncateToDouble() == (_data?.averageScore ?? 0) ? 0 : 1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 4, left: 4),
                                      child: Text('/10', style: TextStyle(color: Colors.white70, fontSize: 16)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.white24,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tỉ lệ đúng', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _getCorrectPercent(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 4, left: 2),
                                      child: Text('%', style: TextStyle(color: Colors.white70, fontSize: 16)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle('Thống kê'),
                    const SizedBox(height: 12),
                    _buildStatGrid(),
                    const SizedBox(height: 20),
                    _sectionTitle('Truy cập nhanh'),
                    const SizedBox(height: 12),
                    _buildQuickActions(context),
                    const SizedBox(height: 12),
                    _historyButton(),
                    const SizedBox(height: 20),
                    _sectionTitle('Chi tiết câu trả lời'),
                    const SizedBox(height: 12),
                    _AnswerCard(data: _data),
                    const SizedBox(height: 20),
                    _sectionTitle('Biểu đồ theo môn'),
                    const SizedBox(height: 12),
                    _SubjectChartsCard(data: _data),
                    const SizedBox(height: 20),
                    _sectionTitle('Biểu đồ kết quả'),
                    const SizedBox(height: 12),
                    _ChartCard(data: _data),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getCorrectPercent() {
    final total = _data?.totalAnswers ?? 0;
    final correct = _data?.totalCorrectAnswers ?? 0;
    if (total == 0) return '0';
    return ((correct / total) * 100).toStringAsFixed(0);
  }

  Widget _buildHeader(String firstName) {
    final theme = context.watch<ThemeProvider>();
    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      stretch: true,
      backgroundColor: theme.primaryColor,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(gradient: theme.gradientPrimary),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: 80,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Xin chào, $firstName!',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'QuizEdu - Học & Thi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: const Icon(Icons.school_rounded, color: Colors.white, size: 26),
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

  Widget _sectionTitle(String title) {
    final theme = context.watch<ThemeProvider>();
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary),
    );
  }

  Widget _buildStatGrid() {
    final theme = context.watch<ThemeProvider>();
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(icon: Icons.book_rounded, label: 'Môn học', value: '${_data?.totalSubjects ?? 0}', gradient: theme.gradientPrimary)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(icon: Icons.description_rounded, label: 'Tài liệu', value: '${_data?.totalDocuments ?? 0}', gradient: theme.gradientAccent)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(icon: Icons.quiz_rounded, label: 'Đề Quiz', value: '${_data?.totalQuizzes ?? 0}', gradient: theme.gradientWarm)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(icon: Icons.assignment_turned_in_rounded, label: 'Lần thi', value: '${_data?.totalExams ?? 0}', gradient: LinearGradient(colors: [theme.primaryDark, theme.primaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight))),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Row(
      children: [
        Expanded(child: _QuickAction(icon: Icons.book_rounded, label: 'Môn học', color: theme.primaryColor, onTap: () => context.go('/subjects'))),
        const SizedBox(width: 12),
        Expanded(child: _QuickAction(icon: Icons.auto_awesome_rounded, label: 'AI Tools', color: theme.accent, onTap: () => context.go('/ai-hub'))),
        const SizedBox(width: 12),
        Expanded(child: _QuickAction(icon: Icons.support_agent_rounded, label: 'Hỗ trợ', color: theme.warning, onTap: () => _showContactDialog(context))),
      ],
    );
  }

  void _showContactDialog(BuildContext context) {
    final theme = context.read<ThemeProvider>();
    final auth = context.read<AuthProvider>();
    final nameController = TextEditingController(text: auth.currentUser?.fullName ?? '');
    final emailController = TextEditingController(text: auth.currentUser?.email ?? '');
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.support_agent_rounded, color: theme.warning),
            const SizedBox(width: 8),
            const Text('Liên hệ hỗ trợ'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Họ tên', prefixIcon: const Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email', prefixIcon: const Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(labelText: 'Chủ đề', prefixIcon: const Icon(Icons.title)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Nội dung',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 60)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
          ElevatedButton.icon(
            onPressed: () async {
              if (nameController.text.isEmpty || emailController.text.isEmpty || subjectController.text.isEmpty || messageController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Vui lòng điền đầy đủ thông tin'), backgroundColor: theme.danger),
                );
                return;
              }
              try {
                await ApiClient.dio.post('/contact', data: {
                  'userName': nameController.text,
                  'email': emailController.text,
                  'subject': subjectController.text,
                  'message': messageController.text,
                });
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Đã gửi yêu cầu hỗ trợ!'), backgroundColor: theme.success),
                );
              } catch (e) {
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e'), backgroundColor: theme.danger),
                );
              }
            },
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  Widget _historyButton() {
    final theme = context.watch<ThemeProvider>();
    return _GlassCardLight(
      onTap: () => context.push('/history'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.history_rounded, color: theme.primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lịch sử bài thi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.textPrimary),
                ),
                Text(
                  'Xem lại các bài thi đã làm',
                  style: TextStyle(fontSize: 12, color: theme.textHint),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.primaryColor, size: 22),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: theme.gradientPrimary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(color: theme.primaryColor.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassCardLight extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const _GlassCardLight({required this.child, this.onTap, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
              boxShadow: [
                BoxShadow(color: theme.primaryColor.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final LinearGradient gradient;

  const _StatCard({required this.icon, required this.label, required this.value, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [BoxShadow(color: gradient.colors.first.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 6))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.1)),
                    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final DashboardModel? data;
  const _AnswerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final total = data?.totalAnswers ?? 0;
    final correct = data?.totalCorrectAnswers ?? 0;
    final wrong = total - correct;
    final percent = total > 0 ? correct / total : 0.0;

    return _GlassCardLight(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.analytics_rounded, color: theme.primaryColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Chi tiết câu trả lời',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Đúng $correct / $total', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
              Text(
                '${(percent * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.success),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: theme.danger.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(theme.success),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _AnswerStat(label: 'Đúng', value: '$correct', color: theme.success, icon: Icons.check_circle_rounded),
              const SizedBox(width: 12),
              _AnswerStat(label: 'Sai', value: '$wrong', color: theme.danger, icon: Icons.cancel_rounded),
              const SizedBox(width: 12),
              _AnswerStat(label: 'Tổng', value: '$total', color: theme.primaryColor, icon: Icons.quiz_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _AnswerStat({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: theme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final DashboardModel? data;
  const _ChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final total = data?.totalAnswers ?? 0;
    final correct = data?.totalCorrectAnswers ?? 0;
    final wrong = total - correct;
    final score = data?.averageScore ?? 0.0;

    final bars = [
      _BarData('Tổng', total, theme.primaryColor),
      _BarData('Đúng', correct, theme.success),
      _BarData('Sai', wrong, theme.danger),
    ];
    final maxVal = bars.map((b) => b.value).fold(0, (a, b) => a > b ? a : b);

    return _GlassCardLight(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.school_rounded, color: theme.primaryColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Phân tích kết quả',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.textPrimary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.gradientPrimary.colors.first.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Điểm TB: ${score.toStringAsFixed(1)}/10',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (total == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('Chưa có dữ liệu', style: TextStyle(color: theme.textHint)),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: bars.map((bar) {
                final ratio = maxVal > 0 ? bar.value / maxVal : 0.0;
                final barH = 120.0 * ratio;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${bar.value}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: bar.color)),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      width: 48,
                      height: barH.clamp(4.0, 120.0),
                      decoration: BoxDecoration(color: bar.color, borderRadius: BorderRadius.circular(8)),
                    ),
                    const SizedBox(height: 8),
                    Text(bar.label, style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                  ],
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hiệu suất học tập', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                  Text(
                    '${((score / 10) * 100).toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (score / 10).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: theme.background,
                  valueColor: AlwaysStoppedAnimation(
                    score >= 8 ? theme.success : score >= 5 ? theme.warning : theme.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubjectChartsCard extends StatefulWidget {
  final DashboardModel? data;
  const _SubjectChartsCard({required this.data});

  @override
  State<_SubjectChartsCard> createState() => _SubjectChartsCardState();
}

class _SubjectChartsCardState extends State<_SubjectChartsCard> {
  String _filterType = 'all'; // all, high, low, medium
  String _sortType = 'name'; // name, score, exams
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<DocumentStats> get _filteredStats {
    var stats = widget.data?.documentStats ?? [];
    
    // Filter by search
    if (_searchQuery.isNotEmpty) {
      stats = stats.where((s) => 
        s.documentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.subjectName.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Filter by score type
    if (_filterType == 'high') {
      stats = stats.where((s) => s.averageScore >= 8).toList();
    } else if (_filterType == 'medium') {
      stats = stats.where((s) => s.averageScore >= 5 && s.averageScore < 8).toList();
    } else if (_filterType == 'low') {
      stats = stats.where((s) => s.averageScore < 5).toList();
    }
    
    // Sort
    switch (_sortType) {
      case 'score':
        stats.sort((a, b) => b.averageScore.compareTo(a.averageScore));
        break;
      case 'exams':
        stats.sort((a, b) => b.totalExams.compareTo(a.totalExams));
        break;
      default:
        stats.sort((a, b) => a.documentName.compareTo(b.documentName));
    }
    
    return stats;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final allStats = widget.data?.documentStats ?? [];

    if (allStats.isEmpty) {
      return _GlassCardLight(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(Icons.description_outlined, size: 48, color: theme.textHint.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                Text('Chưa có dữ liệu theo tài liệu', style: TextStyle(color: theme.textHint)),
                const SizedBox(height: 4),
                Text('Làm bài thi để xem thống kê', style: TextStyle(fontSize: 12, color: theme.textHint)),
              ],
            ),
          ),
        ),
      );
    }

    return _GlassCardLight(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.analytics_rounded, color: theme.primaryColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kết quả theo tài liệu',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_filteredStats.length}/${allStats.length}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm tài liệu...',
              prefixIcon: Icon(Icons.search, color: theme.textHint),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: theme.textHint),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tất cả',
                  selected: _filterType == 'all',
                  onTap: () => setState(() => _filterType = 'all'),
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Giỏi (8+)',
                  selected: _filterType == 'high',
                  onTap: () => setState(() => _filterType = 'high'),
                  theme: theme,
                  color: theme.success,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Trung bình (5-8)',
                  selected: _filterType == 'medium',
                  onTap: () => setState(() => _filterType = 'medium'),
                  theme: theme,
                  color: theme.warning,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Yếu (<5)',
                  selected: _filterType == 'low',
                  onTap: () => setState(() => _filterType = 'low'),
                  theme: theme,
                  color: theme.danger,
                ),
                const SizedBox(width: 16),
                Container(
                  height: 32,
                  width: 1,
                  color: theme.textHint.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 16),
                PopupMenuButton<String>(
                  initialValue: _sortType,
                  onSelected: (v) => setState(() => _sortType = v),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.textHint.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sort, size: 16, color: theme.textSecondary),
                        const SizedBox(width: 4),
                        Text('Sắp xếp', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                      ],
                    ),
                  ),
                  itemBuilder: (ctx) => [
                    PopupMenuItem(value: 'name', child: Text(_sortType == 'name' ? '✓ Theo tên' : 'Theo tên')),
                    PopupMenuItem(value: 'score', child: Text(_sortType == 'score' ? '✓ Theo điểm' : 'Theo điểm')),
                    PopupMenuItem(value: 'exams', child: Text(_sortType == 'exams' ? '✓ Theo số bài thi' : 'Theo số bài thi')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats list with scroll
          if (_filteredStats.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('Không có kết quả phù hợp', style: TextStyle(color: theme.textHint)),
              ),
            )
          else
            SizedBox(
              height: 320,
              child: ListView.builder(
                itemCount: _filteredStats.length,
                itemBuilder: (ctx, index) {
                  final stat = _filteredStats[index];
                  final wrong = stat.totalQuestions - stat.totalCorrect;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _DocumentStatItem(stat: stat, wrong: wrong, theme: theme),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeProvider theme;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? theme.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? chipColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? chipColor : theme.textHint.withValues(alpha: 0.3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? chipColor : theme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DocumentStatItem extends StatelessWidget {
  final DocumentStats stat;
  final int wrong;
  final ThemeProvider theme;

  const _DocumentStatItem({
    required this.stat,
    required this.wrong,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                stat.documentName,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                stat.subjectName,
                style: TextStyle(fontSize: 10, color: theme.textHint),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 28,
            child: Row(
              children: [
                Expanded(
                  flex: stat.totalCorrect > 0 ? stat.totalCorrect : 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.success,
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(6)),
                    ),
                    alignment: Alignment.center,
                    child: stat.totalCorrect > 0
                        ? Text('${stat.totalCorrect} đúng', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))
                        : null,
                  ),
                ),
                if (wrong > 0)
                  Expanded(
                    flex: wrong,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.danger,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(6)),
                      ),
                      alignment: Alignment.center,
                      child: Text('$wrong sai', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${stat.totalExams} bài thi',
              style: TextStyle(fontSize: 11, color: theme.textHint),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (stat.averageScore >= 5 ? theme.success : theme.danger).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${stat.averageScore.toStringAsFixed(1)} điểm TB',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: stat.averageScore >= 5 ? theme.success : theme.danger,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BarData {
  final String label;
  final int value;
  final Color color;
  const _BarData(this.label, this.value, this.color);
}
