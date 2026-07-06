import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
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
  String _selectedGender = '';
  DateTime? _dateOfBirth;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    _nameCtrl.text = user?.fullName ?? '';
    _emailCtrl.text = user?.email ?? '';
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

    final ok = await provider.updateProfile(
      auth,
      _nameCtrl.text.trim(),
      avatarUrl: _avatarUrl,
      gender: _selectedGender.isNotEmpty ? _selectedGender : null,
      dateOfBirth: _dateOfBirth,
    );
    if (mounted && ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cập nhật hồ sơ thành công!'),
          backgroundColor: context.read<ThemeProvider>().success,
        ),
      );
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: context.read<ThemeProvider>().danger,
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    final theme = context.read<ThemeProvider>();
    if (_oldPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty) return;
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mật khẩu mới không khớp!'),
          backgroundColor: theme.danger,
        ),
      );
      return;
    }
    if (_newPassCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mật khẩu tối thiểu 6 ký tự!'),
          backgroundColor: theme.danger,
        ),
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
        SnackBar(
          content: const Text('Đổi mật khẩu thành công!'),
          backgroundColor: theme.success,
        ),
      );
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: theme.danger,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final theme = context.read<ThemeProvider>();
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
            style: ElevatedButton.styleFrom(backgroundColor: theme.danger),
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

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 5),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<ProfileProvider>();
    final user = auth.currentUser;
    final name = user?.fullName ?? '';
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: theme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: theme.gradientPrimary),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 90,
                        height: 90,
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.fullName ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text(
              'Hồ sơ',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ProfileSection(
                  title: 'Thông tin cá nhân',
                  icon: Icons.person_rounded,
                  theme: theme,
                  children: [
                    // Avatar
                    _FieldLabel(label: 'Ảnh đại diện', theme: theme),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person_rounded, color: theme.primaryColor, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _avatarUrl != null ? 'Đã chọn ảnh mới' : 'Chưa có ảnh',
                            style: TextStyle(fontSize: 13, color: theme.textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _avatarUrl = 'avatar_${DateTime.now().millisecondsSinceEpoch}');
                          },
                          child: Text(
                            _avatarUrl != null ? 'Đổi ảnh' : 'Chọn ảnh',
                            style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Name
                    _FieldLabel(label: 'Họ và tên', theme: theme),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.badge_outlined, color: theme.textSecondary),
                        hintText: 'Nhập họ và tên',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Gender
                    _FieldLabel(label: 'Giới tính', theme: theme),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _GenderChip(label: 'Nam', value: 'MALE', selected: _selectedGender, onTap: () => setState(() => _selectedGender = 'MALE'), theme: theme),
                        const SizedBox(width: 10),
                        _GenderChip(label: 'Nữ', value: 'FEMALE', selected: _selectedGender, onTap: () => setState(() => _selectedGender = 'FEMALE'), theme: theme),
                        const SizedBox(width: 10),
                        _GenderChip(label: 'Khác', value: 'OTHER', selected: _selectedGender, onTap: () => setState(() => _selectedGender = 'OTHER'), theme: theme),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date of birth
                    _FieldLabel(label: 'Ngày sinh', theme: theme),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: theme.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cake_outlined, color: theme.textSecondary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _dateOfBirth != null
                                    ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                    : 'Chọn ngày sinh',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _dateOfBirth != null ? theme.textPrimary : theme.textHint,
                                ),
                              ),
                            ),
                            Icon(Icons.calendar_today_rounded, color: theme.textHint, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email (read-only)
                    _FieldLabel(label: 'Email', theme: theme),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined, color: theme.textSecondary),
                        suffixIcon: Icon(Icons.lock_outline, size: 18, color: theme.textHint),
                      ),
                    ),
                    const SizedBox(height: 20),

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
                const SizedBox(height: 16),

                _ProfileSection(
                  title: 'Đổi mật khẩu',
                  icon: Icons.lock_rounded,
                  theme: theme,
                  children: [
                    _PasswordField(
                      controller: _oldPassCtrl,
                      label: 'Mật khẩu hiện tại',
                      obscure: _obscureOld,
                      onToggle: () => setState(() => _obscureOld = !_obscureOld),
                    ),
                    const SizedBox(height: 12),
                    _PasswordField(
                      controller: _newPassCtrl,
                      label: 'Mật khẩu mới',
                      obscure: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    const SizedBox(height: 12),
                    _PasswordField(
                      controller: _confirmPassCtrl,
                      label: 'Xác nhận mật khẩu mới',
                      obscure: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: provider.isSaving ? null : _changePassword,
                        icon: const Icon(Icons.lock_reset_rounded, size: 18),
                        label: const Text('Đổi mật khẩu'),
                        style: ElevatedButton.styleFrom(backgroundColor: theme.accentLight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _ProfileSection(
                  title: 'Tài khoản',
                  icon: Icons.settings_rounded,
                  theme: theme,
                  children: [
                    _MenuTile(
                      icon: Icons.info_outline_rounded,
                      label: 'Phiên bản ứng dụng',
                      trailing: Text('1.0.0', style: TextStyle(color: theme.textSecondary, fontSize: 13)),
                    ),
                    const Divider(height: 1),
                    _MenuTile(
                      icon: Icons.logout_rounded,
                      label: 'Đăng xuất',
                      iconColor: theme.danger,
                      labelColor: theme.danger,
                      onTap: _logout,
                    ),
                  ],
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

class _ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeProvider theme;
  final List<Widget> children;

  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.theme,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
            boxShadow: [
              BoxShadow(color: theme.primaryColor.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 6)),
            ],
          ),
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
                    child: Icon(icon, color: theme.primaryColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final ThemeProvider theme;

  const _FieldLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(fontSize: 12, color: theme.textSecondary, fontWeight: FontWeight.w500),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;
  final ThemeProvider theme;

  const _GenderChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.textHint.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });

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
    final theme = context.watch<ThemeProvider>();
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: iconColor ?? theme.textSecondary, size: 22),
        title: Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: labelColor ?? theme.textPrimary),
        ),
        trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right_rounded, color: theme.textHint, size: 20) : null),
      ),
    );
  }
}
