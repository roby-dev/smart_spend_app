import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_spend_app/features/compras_archivadas/provider/archivadas_provider.dart';
import 'package:smart_spend_app/features/shared/providers/session_provider.dart';
import 'package:smart_spend_app/features/shared/widgets/appbar.dart';
import 'package:smart_spend_app/features/home/providers/home_provider.dart';

class Layout1 extends ConsumerStatefulWidget {
  const Layout1({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Layout1State createState() => Layout1State();
}

class Layout1State extends ConsumerState<Layout1> {
  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final isInArchivadasView =
        GoRouterState.of(context).uri.toString().startsWith('/archivadas');
    final showRestoreOnly = isInArchivadasView && homeState.isComprasSelected;

    return Scaffold(
      appBar: MyAppBar(
        showRestoreOnly: showRestoreOnly,
        onRestore: () async {
          final selectedIds = ref.read(homeProvider).selectedCompras;
          await ref
              .read(archivadasProvider.notifier)
              .restoreSelected(selectedIds);
          ref.read(homeProvider.notifier).deselectAllCompras();
        },
        showDeleteAction: homeState.isComprasSelected,
        onDelete: () async {
          await ref
              .read(homeProvider.notifier)
              .showDeleteConfirmationDialog(context: context);
        },
        onArchive: () async {
          await ref
              .read(homeProvider.notifier)
              .showArchiveConfirmationDialog(context: context);
        },
        onCancel: () {
          ref.read(homeProvider.notifier).toggleComprasSelection();
        },
        exportToJson: () async {
          await ref.read(sessionProvider.notifier).signInAndExport(context);
        },
        importFromJson: () async {
          await ref.read(sessionProvider.notifier).importFromDrive(context);
        },
        signOut: () async {
          await ref.read(sessionProvider.notifier).signOut();
        },
        user: ref.watch(sessionProvider).user,
      ),
      //drawer: const MyDrawer(),
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
