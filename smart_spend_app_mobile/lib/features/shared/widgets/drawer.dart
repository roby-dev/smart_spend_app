import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/auth/providers/auth_provider.dart';
import 'package:smart_spend_app/features/cloud_backup/providers/cloud_backup_provider.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(cloudBackupProvider);
    final authState = ref.watch(authProvider);
    final isBusy = backupState.status == CloudBackupStatus.loading;
    final isSignedIn = authState.status == AuthStatus.signedIn;
    final isSigningIn = authState.status == AuthStatus.signingIn;
    final profile = authState.profile;

    return Drawer(
      backgroundColor: AppColors.gray25,
      surfaceTintColor: AppColors.primary700,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            children: [
              _AccountHeader(
                name: profile?.name,
                email: profile?.email,
                photoUrl: profile?.photoUrl,
                initials: profile?.initials ?? '?',
                isSignedIn: isSignedIn,
                onTap: isSignedIn ? () => _goToProfile(context) : null,
              ),
              const SizedBox(height: 18),
              _DrawerSection(
                children: [
                  _DrawerAction(
                    icon: Icons.person_outline,
                    label: 'Perfil',
                    enabled: isSignedIn,
                    onTap: () => _goToProfile(context),
                  ),
                  _DrawerAction(
                    icon: Icons.cloud_upload_outlined,
                    label: 'Backup en la nube',
                    enabled: !isBusy,
                    onTap: () => _runBackup(context, ref),
                  ),
                  _DrawerAction(
                    icon: Icons.cloud_download_outlined,
                    label: 'Restaurar desde la nube',
                    enabled: !isBusy,
                    onTap: () => _runRestore(context, ref),
                  ),
                ],
              ),
              if (isBusy)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    color: AppColors.primary700,
                    backgroundColor: AppColors.gray200,
                  ),
                ),
              const Spacer(),
              if (isSignedIn)
                _DrawerAction(
                  icon: Icons.logout_rounded,
                  label: 'Cerrar sesion',
                  foregroundColor: AppColors.error500,
                  backgroundColor: AppColors.gray100,
                  onTap: () async {
                    await ref.read(authProvider.notifier).signOut();
                  },
                )
              else
                _DrawerAction(
                  icon: Icons.login_rounded,
                  label: isSigningIn ? 'Iniciando sesion...' : 'Iniciar sesion',
                  enabled: !isSigningIn,
                  foregroundColor: AppColors.primary700,
                  backgroundColor: AppColors.gray100,
                  onTap: () => _signIn(context, ref),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToProfile(BuildContext context) {
    Navigator.pop(context);
    context.push('/profile');
  }

  Future<void> _signIn(BuildContext context, WidgetRef ref) async {
    final signedIn = await ref.read(authProvider.notifier).signInWithGoogle();
    if (!context.mounted) return;
    if (signedIn) return;

    final error = ref.read(authProvider).error;
    if (error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: AppColors.error500),
    );
  }

  Future<void> _runBackup(BuildContext context, WidgetRef ref) async {
    await ref.read(cloudBackupProvider.notifier).backupNow();
    if (!context.mounted) return;
    _showResult(context, ref);
  }

  Future<void> _runRestore(BuildContext context, WidgetRef ref) async {
    await ref.read(cloudBackupProvider.notifier).restoreNow();
    if (!context.mounted) return;
    _showResult(context, ref);
  }

  void _showResult(BuildContext context, WidgetRef ref) {
    final state = ref.read(cloudBackupProvider);
    final message = state.message;
    if (message == null || !context.mounted) return;
    final isError = state.status == CloudBackupStatus.error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error500 : AppColors.gray800,
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.initials,
    required this.isSignedIn,
    this.onTap,
  });

  final String? name;
  final String? email;
  final String? photoUrl;
  final String initials;
  final bool isSignedIn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final title = (name?.trim().isNotEmpty ?? false)
        ? name!.trim()
        : isSignedIn
        ? 'Cuenta conectada'
        : 'Smart Spend';
    final subtitle = (email?.trim().isNotEmpty ?? false)
        ? email!.trim()
        : isSignedIn
        ? 'Sesion activa'
        : 'Inicia sesion para guardar tu backup';

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary700),
          boxShadow: AppColors.shadowSm,
        ),
        child: Row(
          children: [
            _ProfileAvatar(photoUrl: photoUrl, initials: initials, radius: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.gray900,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.gray600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSignedIn)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary700,
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.photoUrl,
    required this.initials,
    required this.radius,
  });

  final String? photoUrl;
  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.gray200,
      backgroundImage: hasPhoto ? NetworkImage(photoUrl!.trim()) : null,
      child: hasPhoto
          ? null
          : Text(
              initials,
              style: const TextStyle(
                color: AppColors.primary700,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(children: children),
    );
  }
}

class _DrawerAction extends StatelessWidget {
  const _DrawerAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.foregroundColor,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? foregroundColor ?? AppColors.gray800
        : AppColors.gray500;

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: enabled ? AppColors.gray100 : AppColors.gray100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: enabled ? AppColors.gray500 : AppColors.gray300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
