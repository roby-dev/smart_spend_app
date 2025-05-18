import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';
import 'package:smart_spend_app/models/compra_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';
import 'package:smart_spend_app/features/shared/widgets/checkbox_rounded.dart';
import 'package:smart_spend_app/models/compra_model.dart';

class ComprasCard extends ConsumerWidget {
  final CompraModel compra;
  final bool disableLongPress;
  final bool enableShake;

  const ComprasCard({
    super.key,
    required this.compra,
    this.disableLongPress = false,
    this.enableShake = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final isSelected = homeState.selectedCompras.contains(compra.id);
    final isMultiSelectMode = homeState.isComprasSelected;
    final isArchivada = compra.archivado;

    final total = compra.detalles.fold(0.0, (sum, d) => sum + d.precio);

    final tile = Stack(
      children: [
        ListTile(
          onTap: () async {
            if (isMultiSelectMode) {
              ref.read(homeProvider.notifier).toggleCompraSelection(compra.id!);
            } else if (!isArchivada) {
              await ref
                  .read(homeProvider.notifier)
                  .goDetalleCompra(compra: compra);
            }
          },
          onLongPress: disableLongPress
              ? null
              : () {
                  ref.read(homeProvider.notifier).toggleComprasSelection();
                  ref
                      .read(homeProvider.notifier)
                      .toggleCompraSelection(compra.id!);
                },
          title: Text(
            compra.titulo,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          contentPadding: EdgeInsets.only(
            top: 0,
            bottom: 16,
            left: isMultiSelectMode ? 40 : 16,
            right: 16,
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'S/ ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.gray700,
                ),
              ),
            ],
          ),
          tileColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          selected: isSelected,
          selectedTileColor: Colors.grey.shade200,
        ),

        // ⬇️ Mostrar checkbox solo si está en modo selección y no en modo reordenar
        if (isMultiSelectMode && !disableLongPress)
          Positioned(
            top: 4,
            left: 0,
            child: RoundedCheckbox(
              value: isSelected,
              onChanged: (value) {
                ref
                    .read(homeProvider.notifier)
                    .toggleCompraSelection(compra.id!);
              },
            ),
          ),
      ],
    );

    final content = enableShake ? _ShakeAnimation(child: tile) : tile;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: content,
    );
  }
}

class _ShakeAnimation extends StatefulWidget {
  final Widget child;
  const _ShakeAnimation({required this.child});

  @override
  State<_ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<_ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
