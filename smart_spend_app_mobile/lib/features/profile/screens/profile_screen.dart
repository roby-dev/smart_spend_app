import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profile = authState.profile;
    final name = (profile?.name?.trim().isNotEmpty ?? false)
        ? profile!.name!.trim()
        : 'Usuario';
    final email = (profile?.email?.trim().isNotEmpty ?? false)
        ? profile!.email!.trim()
        : 'Sin correo disponible';
    final initials = profile?.initials ?? '?';
    final photoUrl = profile?.photoUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perfil',
            style: TextStyle(
              color: AppColors.gray900,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.primary700),
              boxShadow: AppColors.shadowSm,
            ),
            child: Column(
              children: [
                _ProfilePhoto(photoUrl: photoUrl, initials: initials),
                const SizedBox(height: 16),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.gray900,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.gray600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoTile(
            icon: Icons.verified_user_outlined,
            label: 'Estado',
            value: authState.status == AuthStatus.signedIn
                ? 'Sesion activa'
                : 'Sin sesion',
          ),
          _InfoTile(
            icon: Icons.account_circle_outlined,
            label: 'Proveedor',
            value: 'Google',
          ),
          _InfoTile(
            icon: Icons.cloud_done_outlined,
            label: 'Backup',
            value: authState.status == AuthStatus.signedIn
                ? 'Disponible'
                : 'Requiere iniciar sesion',
          ),
        ],
      ),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.photoUrl, required this.initials});

  final String? photoUrl;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return Container(
      width: 104,
      height: 104,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary700, width: 2),
        color: AppColors.gray100,
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.gray200,
        backgroundImage: hasPhoto ? NetworkImage(photoUrl!.trim()) : null,
        child: hasPhoto
            ? null
            : Text(
                initials,
                style: const TextStyle(
                  color: AppColors.primary700,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.primary700, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.gray500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.gray900,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
