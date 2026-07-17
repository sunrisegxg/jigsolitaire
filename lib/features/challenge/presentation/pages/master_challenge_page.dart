import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jigsolitaire/core/services/interaction_service.dart';

import '../../../game_progress/presentation/bloc/game_progress_bloc.dart';
import '../../../puzzle/presentation/widgets/level_clear/coin_wallet.dart';
import '../../domain/entities/challenge_level.dart';

class MasterChallengePage extends StatefulWidget {
  const MasterChallengePage({super.key});

  @override
  State<MasterChallengePage> createState() => _MasterChallengePageState();
}

class _MasterChallengePageState extends State<MasterChallengePage> {
  final levels = List.generate(
    12,
    (index) => ChallengeLevel(
      id: index + 1,
      unlocked: index == 0,
      price: index == 0 ? 1000 : null,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final walletCoins = context.watch<GameProgressBloc>().state.progress.coins;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png', // ảnh nền của bạn
              fit: BoxFit.cover,
            ),
          ),
          Positioned(top: 50, right: 20, child: CoinWallet(coins: walletCoins)),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.04,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.025,
                      right: MediaQuery.of(context).size.width * 0.025,
                      bottom: MediaQuery.of(context).size.height * 0.025,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await context.read<InteractionService>().tap();
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF056E45),
                              size: 40,
                            ),
                          ),
                        ),

                        const Text(
                          'Master Challenge',
                          style: TextStyle(
                            color: Color(0xFF056E45),
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      itemCount: levels.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          ),
                      itemBuilder: (context, index) {
                        final item = levels[index];

                        return GestureDetector(
                          onTap: () async {
                            await context.read<InteractionService>().tap();
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF748A84),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.green.shade900,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        "assets/images/backcard2.jpg",
                                        fit: BoxFit.cover,
                                      ),

                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black.withValues(alpha: 0),
                                              Colors.black.withValues(
                                                alpha: 0.35,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Label giống Collection
                                      Positioned(
                                        top: 6,
                                        left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.4,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            "Level ${item.id}", // <-- đổi ở đây
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Nếu chưa mở thì hiện khóa
                                      if (!item.unlocked) // <-- đổi ở đây
                                        const Center(
                                          child: Icon(
                                            Icons.lock,
                                            color: Colors.white,
                                            size: 50,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              // Chỉ hiện giá khi đã mở
                              if (item.unlocked) // <-- đổi ở đây
                                Positioned(
                                  bottom: 0,
                                  left: 10,
                                  right: 10,
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade900,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.monetization_on,
                                          color: Color(0xFFFFC107),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "${item.price}", // <-- đổi ở đây
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
