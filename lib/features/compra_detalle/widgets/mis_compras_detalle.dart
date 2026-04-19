import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/compra_detalle/providers/compra_detalle_provider.dart';
import 'package:smart_spend_app/features/compra_detalle/widgets/mis_compras_detalle_skeleton.dart';
import 'package:smart_spend_app/features/shared/utils/utils.dart';
import 'package:smart_spend_app/domain/models/compra_detalle_model.dart';

class MisComprasDetalle extends ConsumerWidget {
  const MisComprasDetalle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compraDetalleState = ref.watch(compraDetalleProvider);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: compraDetalleState.isLoading
          ? ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: 2, // Muestra 5 skeletons
              separatorBuilder: (context, index) => const Divider(
                color: AppColors.gray100,
                height: 0,
                thickness: 1,
              ),
              itemBuilder: (context, index) =>
                  const ComprasDetalleRowSkeleton(),
            )
          : ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: compraDetalleState.detalles.length,
              separatorBuilder: (context, index) => const Divider(
                color: AppColors.gray100,
                height: 0, // Reduce el espacio entre los ítems
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final compraDetalle = compraDetalleState.detalles[index];
                return _AnimatedDismissible(
                  compraDetalle: compraDetalle,
                  index: index,
                  onDismissed: () async {
                    await ref
                        .read(compraDetalleProvider.notifier)
                        .deleteCurrentCompraDetalle(compraDetalle.id!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Compra eliminada'),
                          action: SnackBarAction(
                            label: 'Deshacer',
                            onPressed: () async {
                              await ref
                                  .read(compraDetalleProvider.notifier)
                                  .addDetalle(compraDetalle);
                            },
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}

class _ComprasDetalleRow extends ConsumerStatefulWidget {
  final CompraDetalleModel compraDetalle;
  final int index;

  const _ComprasDetalleRow({required this.compraDetalle, required this.index});

  @override
  _ComprasDetalleRowState createState() => _ComprasDetalleRowState();
}

class _ComprasDetalleRowState extends ConsumerState<_ComprasDetalleRow> {
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late FocusNode _nombreFocusNode;
  late FocusNode _precioFocusNode;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.compraDetalle.nombre,
    );
    _precioController = TextEditingController(
      text: widget.compraDetalle.precio.toStringAsFixed(2),
    );
    _nombreFocusNode = FocusNode();
    _precioFocusNode = FocusNode();

    _nombreFocusNode.addListener(_onFocusChange);
    _precioFocusNode.addListener(_onPrecioFocus);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _nombreFocusNode.dispose();
    _precioFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_nombreFocusNode.hasFocus) {
      _saveDetalle();
    }
  }

  void _onPrecioFocus() {
    if (_precioFocusNode.hasFocus) {
      if (_precioController.text == '0.00' || _precioController.text == '0') {
        _precioController.clear();
      }
    } else {
      _saveDetalle();
    }
  }

  Future<void> _saveDetalle() async {
    final newNombre = _nombreController.text.trim();
    final newPrecioText = _precioController.text.trim();
    final newPrecio = double.tryParse(newPrecioText) ?? 0.00;

    final formattedPrecio = double.parse(newPrecio.toStringAsFixed(2));
    _precioController.text = formattedPrecio.toStringAsFixed(2);

    if (newNombre.isNotEmpty &&
        (newNombre != widget.compraDetalle.nombre ||
            formattedPrecio != widget.compraDetalle.precio)) {
      final updatedDetalle = CompraDetalleModel(
        id: widget.compraDetalle.id,
        nombre: newNombre,
        precio: formattedPrecio,
        compraId: widget.compraDetalle.compraId,
        fecha: widget.compraDetalle.fecha,
      );

      await ref
          .read(compraDetalleProvider.notifier)
          .updateDetalle(widget.index, updatedDetalle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 15, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nombreController,
                  focusNode: _nombreFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Nombre',
                    border: InputBorder.none,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.gray500,
                        width: 1.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    overflow: TextOverflow.ellipsis,
                  ),
                  //onSubmitted: (_) async => await _saveDetalle(),
                ),
              ),
              const SizedBox(width: 8.0), // Space between fields
              const Text(
                'S/',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w300,
                  color: AppColors.gray500,
                ),
              ),
              const SizedBox(width: 5.0),
              SizedBox(
                width: 70,
                child: TextField(
                  textAlign: TextAlign.end,
                  controller: _precioController,
                  focusNode: _precioFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Precio',
                    border: InputBorder.none,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.gray500,
                        width: 1.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w300,
                    color: AppColors.gray700,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          Text(
            Utils.FormattedDate(compraFecha: widget.compraDetalle.fecha),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDismissible extends StatefulWidget {
  final CompraDetalleModel compraDetalle;
  final int index;
  final VoidCallback onDismissed;

  const _AnimatedDismissible({
    required this.compraDetalle,
    required this.index,
    required this.onDismissed,
  });

  @override
  State<_AnimatedDismissible> createState() => _AnimatedDismissibleState();
}

class _AnimatedDismissibleState extends State<_AnimatedDismissible>
    with SingleTickerProviderStateMixin {
  double _dragExtent = 0;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _shaking = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0, end: -0.15), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.15), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.15, end: -0.08), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -0.08, end: 0.0), weight: 1),
      ],
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onUpdate(DismissUpdateDetails details) {
    final newExtent = details.progress;
    if (!_shaking && newExtent > 0.3) {
      _shaking = true;
      _shakeController.forward(from: 0);
    } else if (newExtent < 0.25) {
      _shaking = false;
    }
    setState(() => _dragExtent = newExtent);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _dragExtent.clamp(0.0, 1.0);
    final iconScale = (0.5 + progress * 1.0).clamp(0.5, 1.2);
    final bgOpacity = (progress * 0.8).clamp(0.0, 0.6);
    final iconOpacity = (progress * 2.5).clamp(0.0, 1.0);

    final bgColor = Color.lerp(
      Colors.purple.shade50,
      Colors.purple.shade300,
      progress.clamp(0.0, 1.0),
    )!;

    return Dismissible(
      key: Key(widget.compraDetalle.id!.toString()),
      onUpdate: _onUpdate,
      onDismissed: (_) => widget.onDismissed(),
      background: Container(
        color: bgColor.withValues(alpha: bgOpacity + 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.centerLeft,
        child: _buildAnimatedIcon(iconScale, iconOpacity),
      ),
      secondaryBackground: Container(
        color: bgColor.withValues(alpha: bgOpacity + 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.centerRight,
        child: _buildAnimatedIcon(iconScale, iconOpacity),
      ),
      child: _ComprasDetalleRow(
        compraDetalle: widget.compraDetalle,
        index: widget.index,
      ),
    );
  }

  Widget _buildAnimatedIcon(double scale, double opacity) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: _shakeAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
