import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/constants/app_colors.dart';

class Layout2 extends ConsumerStatefulWidget {
  const Layout2({
    super.key,
    required this.child,
    this.onBack,
  });

  final Widget child;
  final Future<void> Function()? onBack;

  @override
  Layout2State createState() => Layout2State();
}

class Layout2State extends ConsumerState<Layout2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              context.pop();
            }
          },
          color: AppColors.gray700,
          iconSize: 30,
        ),
        backgroundColor: AppColors.gray100,
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: widget.child,
            )
          ],
        ),
      ),
    );
  }
}
