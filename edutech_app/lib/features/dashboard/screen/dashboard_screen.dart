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
        Expanded(child: _QuickAction(icon: Icons.person_rounded, label: 'Hồ sơ', color: theme.primaryDark, onTap: () => context.go('/profile'))),
      ],
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

class _BarData {
  final String label;
  final int value;
  final Color color;
  const _BarData(this.label, this.value, this.color);
}
