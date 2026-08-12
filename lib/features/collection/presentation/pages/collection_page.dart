import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../../../core/services/interaction_service.dart';
import '../../../game_progress/presentation/bloc/game_progress_bloc.dart';
import '../../domain/entities/collection_item.dart';
import '../bloc/collection_bloc.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InjectionContainer.createCollectionBloc(
        context.read<GameProgressBloc>(),
      ),
      child: const _CollectionView(),
    );
  }
}

class _CollectionView extends StatelessWidget {
  const _CollectionView();

  @override
  Widget build(BuildContext context) {
    final items = context.watch<CollectionBloc>().state.items;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 20,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () async {
                            await context.read<InteractionService>().tap();
                            if (context.mounted) Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.close,
                            size: 36,
                            color: Color(0xFF056E45),
                          ),
                        ),
                      ),
                      const Text(
                        'Collection',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF056E45),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: .75,
                        ),
                    itemBuilder: (context, index) =>
                        _CollectionCard(item: items[index]),
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

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.item});
  final CollectionItem item;

  @override
  Widget build(BuildContext context) {
    final completed = item.state == CollectionProgressState.completed;
    return GestureDetector(
      onTap: completed
          ? () async {
              await context.read<InteractionService>().tap();
              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _CollectionPreview(item: item),
                ),
              );
            }
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (completed || item.state == CollectionProgressState.inProgress)
              Image.asset(
                item.definition.collectionImageAsset,
                fit: BoxFit.cover,
              )
            else
              Image.asset('assets/images/backcard2.png', fit: BoxFit.cover),
            if (!completed)
              ColoredBox(color: Colors.black.withValues(alpha: .42)),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.definition.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(_label, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            if (item.state == CollectionProgressState.locked)
              const Center(
                child: Icon(Icons.lock, size: 46, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  String get _label => switch (item.state) {
    CollectionProgressState.locked => 'Locked',
    CollectionProgressState.inProgress =>
      '${item.completedCount}/${item.definition.levelCount}',
    CollectionProgressState.completed => 'Completed',
    CollectionProgressState.comingSoon => 'Coming soon',
  };
}

class _CollectionPreview extends StatelessWidget {
  const _CollectionPreview({required this.item});

  final CollectionItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(item.definition.collectionImageAsset, fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: const CircleBorder(),
                  elevation: 6,
                  child: IconButton(
                    tooltip: 'Close',
                    onPressed: () async {
                      await context.read<InteractionService>().tap();
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
