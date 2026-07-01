import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameCtrl.text = auth.currentUser?.fullName ?? '';
    _emailCtrl.text = auth.currentUser?.email ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final provider = context.read<ProfileProvider>();
    final auth = context.read<AuthProvider>();
    final ok = await provider.updateProfile(auth, _nameCtrl.text.trim());
    if (mounted && ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Cập nhật hồ sơ thành công!'), backgroundColor: AppColors.success),
      );
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _changePassword() async {
    if (_oldPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty) return;
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới không khớp!'), backgroundColor: AppColors.danger),
      );
      return;
    }
    if (_newPassCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu tối thiểu 6 ký tự!'), backgroundColor: AppColors.danger),
      );
      return;
    }
    final provider = context.read<ProfileProvider>();
    final ok = await provider.changePassword(_oldPassCtrl.text, _newPassCtrl.text);
    if (mounted && ok) {
      _oldPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đổi mật khẩu thành công!'), backgroundColor: AppColors.success),
      );
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final router = GoRouter.of(context);
      await context.read<AuthProvider>().logout();
      router.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<ProfileProvider>();
    final user = auth.currentUser;
    final name = user?.fullName ?? '';
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: const Text('Hồ sơ',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.white24, Colors.white10],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(user?.fullName ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionCard(
                  title: 'Thông tin cá nhân',
                  icon: Icons.person_rounded,
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        readOnly: true,
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          suffixIcon: Icon(Icons.lock_outline, size: 18),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: provider.isSaving ? null : _saveProfile,
                          icon: provider.isSaving
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.save_rounded, size: 18),
                          label: const Text('Lưu thay đổi'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Đổi mật khẩu',
                  icon: Icons.lock_rounded,
                  child: Column(
                    children: [
                      _PassField(
                        controller: _oldPassCtrl,
                        label: 'Mật khẩu hiện tại',
                        obscure: _obscureOld,
                        onToggle: () => setState(() => _obscureOld = !_obscureOld),
                      ),
                      const SizedBox(height: 12),
                      _PassField(
                        controller: _newPassCtrl,
                        label: 'Mật khẩu mới',
                        obscure: _obscureNew,
                        onToggle: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      const SizedBox(height: 12),
                      _PassField(
                        controller: _confirmPassCtrl,
                        label: 'Xác nhận mật khẩu mới',
                        obscure: _obscureConfirm,
                        onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: provider.isSaving ? null : _changePassword,
                          icon: const Icon(Icons.lock_reset_rounded, size: 18),
                          label: const Text('Đổi mật khẩu'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentLight),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Tài khoản',
                  icon: Icons.settings_rounded,
                  child: Column(
                    children: [
                      if (user?.role == 'ADMIN') ...[
                        _MenuTile(
                          icon: Icons.admin_panel_settings_rounded,
                          label: 'Quản trị hệ thống',
                          iconColor: AppColors.warning,
                          labelColor: AppColors.textPrimary,
                          onTap: () => context.push('/admin'),
                        ),
                        const Divider(height: 1),
                      ],
                      _MenuTile(
                        icon: Icons.info_outline_rounded,
                        label: 'Phiên bản ứng dụng',
                        trailing: const Text('1.0.0', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ),
                      const Divider(height: 1),
                      _MenuTile(
                        icon: Icons.logout_rounded,
                        label: 'Đăng xuất',
                        iconColor: AppColors.danger,
                        labelColor: AppColors.danger,
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _PassField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;

  const _PassField({required this.controller, required this.label, required this.obscure, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.iconColor,
    this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 22),
        title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: labelColor ?? AppColors.textPrimary)),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20) : null),
      ),
    );
  }
}
