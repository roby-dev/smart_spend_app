import 'package:flutter/material.dart';
import 'package:smart_spend_app/features/shared/widgets/appbar_2.dart';

class Layout2 extends StatelessWidget {
  const Layout2({
    super.key,
    required this.child,
    this.onBack,
  });

  final Widget child;
  final Future<void> Function()? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar2(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
