import 'dart:math';

import 'package:flutter/material.dart';
import 'package:test/core/enum/game_phase.dart';
import 'package:test/model/puzzle_piece.dart';
import 'package:test/widgets/animation/group_pulse_wrapper.dart';
import 'package:test/widgets/card_back_widget.dart';
import 'package:test/widgets/puzzle_tile_widget.dart';

// --- MAIN SCREEN ---
class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  List<PuzzlePiece> board = [];
  // final int gridSize = 4;
  final int gridSize = 4;
  int? draggingGroupId;
  double aspectRatio = 0.7;

  bool _isProcessingDrop = false;

  // State Animations
  GamePhase _gamePhase = GamePhase.dealing;
  int _dealIndex = 0;
  Set<int> pulsingGroups = {}; // Lưu ID các cụm đang có hiệu ứng co giãn
  bool _hasPlayedIntroFlip =
      false; // biến cờ để đảm bảo hiệu ứng lật bài chỉ chạy 1 lần duy nhất ở đầu game

  // Khóa kiểm tra xem lượt kéo này có hoán đổi thành công hay không
  bool _didSwap = false;

  // Lưu trữ khoảng cách lệch (Delta) của từng mảnh để bay về chỗ cũ
  final Map<int, Offset> _snapBackOffsets = {};

  // Key để xác định tọa độ gốc của vùng chứa Stack
  final GlobalKey _stackKey = GlobalKey();

  final Image puzzleImage = Image.asset(
    'assets/puzzle_image.jpg',
    fit: BoxFit.cover,
  );

  @override
  void initState() {
    super.initState();
    _initBoard();
    _runStartSequence();
  }

  void _initBoard() {
    board = List.generate(16, (index) {
      return PuzzlePiece(id: index, currentIndex: index, groupId: index);
    });

    board.shuffle(Random());
    for (int i = 0; i < board.length; i++) {
      board[i].currentIndex = i;
    }

    _updateGroups();
  }

  // Chuỗi hiệu ứng mở màn: Chia bài -> Chờ -> Lật bài -> Chơi
  void _runStartSequence() async {
    setState(() {
      _gamePhase = GamePhase.dealing;
      _dealIndex = 0;
      pulsingGroups.clear();
      _hasPlayedIntroFlip = false;
    });

    for (int i = 0; i < 16; i++) {
      await Future.delayed(const Duration(milliseconds: 70));
      if (mounted) {
        setState(() => _dealIndex = i + 1);
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() => _gamePhase = GamePhase.flipping);
    }

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _gamePhase = GamePhase.playing;
        _hasPlayedIntroFlip = true;
      });
    }
  }

  int _find(List<int> parent, int i) {
    if (parent[i] == i) return i;
    return parent[i] = _find(parent, parent[i]);
  }

  void _union(List<int> parent, int i, int j) {
    int rootI = _find(parent, i);
    int rootJ = _find(parent, j);
    if (rootI != rootJ) {
      parent[rootI] = rootJ;
    }
  }

  void _updateGroups() {
    List<int> parent = List.generate(16, (index) => index);

    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        int currIdx = y * gridSize + x;
        PuzzlePiece p = board[currIdx];

        if (x < gridSize - 1) {
          PuzzlePiece rightP = board[currIdx + 1];
          if (p.origX + 1 == rightP.origX && p.origY == rightP.origY) {
            _union(parent, p.id, rightP.id);
          }
        }
        if (y < gridSize - 1) {
          PuzzlePiece bottomP = board[currIdx + gridSize];
          if (p.origX == bottomP.origX && p.origY + 1 == bottomP.origY) {
            _union(parent, p.id, bottomP.id);
          }
        }
      }
    }

    for (int i = 0; i < 16; i++) {
      board[i].groupId = _find(parent, board[i].id);
    }
  }

  void _onDrop(int dragIndex, int dropIndex) {
    if (dragIndex == dropIndex) return;

    // THÊM LỚP BẢO VỆ ĐẦU VÀO
    if (_isProcessingDrop) return;

    //đánh dấu đã có thao tác thay đổi vị trí
    _didSwap = true;

    PuzzlePiece draggedPiece = board[dragIndex];
    int dragX = dragIndex % gridSize;
    int dragY = dragIndex ~/ gridSize;
    int dropX = dropIndex % gridSize;
    int dropY = dropIndex ~/ gridSize;

    int dx = dropX - dragX;
    int dy = dropY - dragY;

    List<PuzzlePiece> groupPieces = board
        .where((p) => p.groupId == draggedPiece.groupId)
        .toList();

    bool outOfBounds = false;
    for (var p in groupPieces) {
      int nx = (p.currentIndex % gridSize) + dx;
      int ny = (p.currentIndex ~/ gridSize) + dy;
      if (nx < 0 || nx >= gridSize || ny < 0 || ny >= gridSize) {
        outOfBounds = true;
        break;
      }
    }

    if (outOfBounds) return;

    // LƯU TRẠNG THÁI TRƯỚC KHI GỘP ĐỂ SO SÁNH
    Map<int, int> oldGroupMap = {for (var p in board) p.id: p.groupId};
    int oldDraggedGroupId = draggedPiece.groupId;

    Set<int> oldIndices = groupPieces.map((p) => p.currentIndex).toSet();
    Set<int> newIndices = groupPieces.map((p) {
      int nx = (p.currentIndex % gridSize) + dx;
      int ny = (p.currentIndex ~/ gridSize) + dy;
      return ny * gridSize + nx;
    }).toSet();

    List<int> gaps = oldIndices.difference(newIndices).toList();
    List<int> displacedIndices = newIndices.difference(oldIndices).toList();
    List<PuzzlePiece> displacedPieces = displacedIndices
        .map((idx) => board[idx])
        .toList();

    setState(() {
      //Khóa thao tác ngay khi bắt đầu đổi vị trí để tránh lỗi khi người chơi cố gắng kéo thêm mảnh khác trong lúc animation đang chạy
      _isProcessingDrop = true;

      List<PuzzlePiece> nextBoard = List.from(board);

      for (var p in groupPieces) {
        int nx = (p.currentIndex % gridSize) + dx;
        int ny = (p.currentIndex ~/ gridSize) + dy;
        int newIdx = ny * gridSize + nx;
        nextBoard[newIdx] = p;
      }

      for (int i = 0; i < displacedPieces.length; i++) {
        nextBoard[gaps[i]] = displacedPieces[i];
      }

      for (int i = 0; i < 16; i++) {
        nextBoard[i].currentIndex = i;
      }

      board = nextBoard;

      // để delay cho updategroups giúp tránh bị merge border trước khi mảnh bay vào
      // Gọi một khối hàm async (vô danh) để xử lý chuỗi animation tuần tự
      () async {
        try {
          // 1. Đợi bay vào vị trí
          await Future.delayed(const Duration(milliseconds: 450));
          if (!mounted) return;

          // 2. Tính toán gộp cụm (Merge)
          Set<int> mergedGroupIds = {};
          setState(() {
            _updateGroups();

            Map<int, List<PuzzlePiece>> newGroups = {};
            for (final p in board) {
              newGroups.putIfAbsent(p.groupId, () => []).add(p);
            }

            for (final entry in newGroups.entries) {
              final pieces = entry.value;
              final oldGroupIds = pieces.map((p) => oldGroupMap[p.id]!).toSet();
              if (oldGroupIds.length > 1) {
                mergedGroupIds.add(entry.key);
              }
            }
          });

          if (mergedGroupIds.isEmpty) return; // Không có merge thì thoát sớm

          // 3. Đợi ổn định rồi bơm Pulse
          await Future.delayed(const Duration(milliseconds: 50));
          if (!mounted) return;

          setState(() {
            pulsingGroups.addAll(mergedGroupIds);
          });

          // 4. Đợi Pulse chạy xong
          await Future.delayed(const Duration(milliseconds: 400));
          if (!mounted) return;

          setState(() {
            pulsingGroups.removeAll(mergedGroupIds);
          });
        } finally {
          //tắt drop processing khi kết thúc
          // Dù code có lỗi giữa chừng, nhánh finally vẫn sẽ chạy để mở khóa game
          if (mounted) {
            setState(() {
              _isProcessingDrop = false;
            });
          }
        }
      }();
    });
  }

  Widget _buildGroupFeedback(PuzzlePiece draggedPiece, double tileSize) {
    double tileWidth = tileSize;
    double tileHeight = tileSize / aspectRatio;

    List<PuzzlePiece> groupPieces = board
        .where((p) => p.groupId == draggedPiece.groupId)
        .toList();

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: tileWidth,
        height: tileHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: groupPieces.map((p) {
            int dx =
                (p.currentIndex % gridSize) -
                (draggedPiece.currentIndex % gridSize);
            int dy =
                (p.currentIndex ~/ gridSize) -
                (draggedPiece.currentIndex ~/ gridSize);

            return Positioned(
              left: dx * tileWidth,
              top: dy * tileHeight,
              width: tileWidth,
              height: tileHeight,
              child: PuzzleTileWidget(
                key: ValueKey('feedback_${p.id}'),
                piece: p,
                board: board,
                image: puzzleImage,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 93, 6),
      appBar: AppBar(
        title: const Text('Cluster Puzzle Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _initBoard();
              _runStartSequence();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // SizedBox(height: 104.0),
          SizedBox(height: 10.0),
          Center(
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 1. TÍNH TOÁN KÍCH THƯỚC CHI TIẾT
                    // tự tính width và height dựa trên aspectRatio
                    double tileWidth = constraints.maxWidth / gridSize;
                    double tileHeight = tileWidth / aspectRatio;

                    return SizedBox(
                      width: constraints.maxWidth,
                      height:
                          tileHeight *
                          gridSize, // Chốt cứng không gian cho Stack
                      child: Stack(
                        key: _stackKey,
                        clipBehavior: Clip.none,
                        // Dùng vòng lặp map thay vì GridView.builder
                        children: board.map((piece) {
                          // Lấy vị trí thực tế trên lưới của mảnh ghép
                          int index = piece.currentIndex;

                          bool isPartOfDraggingGroup =
                              draggingGroupId == piece.groupId;
                          bool isDealt =
                              _gamePhase != GamePhase.dealing ||
                              index < _dealIndex;

                          Widget baseBox = Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );

                          Widget currentWidget;

                          // Logic chờ chia bài
                          if (!isDealt) {
                            if (index == 15) {
                              currentWidget = const CardBackWidget();
                            } else {
                              currentWidget = baseBox;
                            }
                          } else {
                            // [0. LÕI WIDGET]
                            Widget tileContent = PuzzleTileWidget(
                              key: ValueKey('tile_${piece.id}'),
                              piece: piece,
                              board: board,
                              image: puzzleImage,
                            );

                            // [1. BỌC SNAP BACK - HIỆU ỨNG BAY VỀ CHỖ CŨ KHI THẢ TẠI CHỖ / RA NGOÀI]
                            final snapOffset = _snapBackOffsets[piece.id];
                            if (snapOffset != null) {
                              tileContent = TweenAnimationBuilder<Offset>(
                                key: ValueKey('snap_back_${piece.id}'),
                                tween: Tween<Offset>(
                                  begin: snapOffset,
                                  end: Offset.zero,
                                ),
                                duration: const Duration(
                                  milliseconds: 500,
                                ), // Tốc độ bay về
                                curve: Curves
                                    .easeOutCubic, // Phanh mượt khi về đích
                                onEnd: () {
                                  // Bay về đích xong thì xóa offset đi để trả lại vị trí lưới tĩnh
                                  setState(() {
                                    _snapBackOffsets.remove(piece.id);
                                  });
                                },
                                builder: (context, offset, child) {
                                  return Transform.translate(
                                    offset: offset,
                                    child: child,
                                  );
                                },
                                child: tileContent,
                              );
                            }

                            // [2. BỌC PULSE]
                            tileContent = GroupPulseWrapper(
                              trigger: pulsingGroups.contains(piece.groupId),
                              piece: piece,
                              board: board,
                              gridSize: gridSize,
                              child: tileContent,
                            );

                            // [3. BỌC FLIP]
                            if (!_hasPlayedIntroFlip) {
                              final double flipTarget =
                                  (_gamePhase == GamePhase.flipping) ? 0.0 : pi;
                              tileContent = TweenAnimationBuilder<double>(
                                key: ValueKey('intro_flip_${piece.id}'),
                                tween: Tween(begin: pi, end: flipTarget),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOut,
                                builder: (context, val, child) {
                                  final bool isFront = val < pi / 2;
                                  return Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(val),
                                    child: isFront
                                        ? child
                                        : Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.identity()
                                              ..rotateY(pi),
                                            child: const CardBackWidget(),
                                          ),
                                  );
                                },
                                child: tileContent,
                              );
                            }

                            // [4. BỌC DEALING]
                            if (_gamePhase == GamePhase.dealing &&
                                index < _dealIndex) {
                              int dx = 3 - (index % 4);
                              int dy = 3 - (index ~/ 4);
                              tileContent = TweenAnimationBuilder<double>(
                                key: ValueKey('deal_${piece.id}'),
                                tween: Tween(begin: 1.0, end: 0.0),
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                builder: (context, val, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      val *
                                          dx *
                                          tileWidth, // Chú ý: dùng tileWidth/tileHeight thay vì tileSize
                                      val * dy * tileHeight,
                                    ),
                                    child: child,
                                  );
                                },
                                child: tileContent,
                              );
                            }

                            // [5. BỌC KÉO THẢ (DragTarget & Draggable)]
                            currentWidget = DragTarget<int>(
                              // 1. Chặn việc nhận mảnh (thả tay) nếu đang dropprocessing
                              onWillAcceptWithDetails: (details) =>
                                  _gamePhase == GamePhase.playing &&
                                  !_isProcessingDrop,
                              onAcceptWithDetails: (details) =>
                                  _onDrop(details.data, index),
                              builder: (context, candidateData, rejectedData) {
                                // 2. TẠO ĐIỀU KIỆN CHẶN NHIỀU NGÓN TAY
                                bool canDrag =
                                    _gamePhase == GamePhase.playing &&
                                    !_isProcessingDrop &&
                                    (draggingGroupId == null ||
                                        draggingGroupId == piece.groupId);

                                return Draggable<int>(
                                  maxSimultaneousDrags: canDrag ? 1 : 0,
                                  data: index,
                                  onDragStarted: () {
                                    _didSwap =
                                        false; //RESET TRẠNG THÁI KHI BẮT ĐẦU KÉO LƯỢT MỚI
                                    setState(() {
                                      draggingGroupId = piece.groupId;
                                    });
                                  },
                                  onDragEnd: (details) {
                                    setState(() {
                                      draggingGroupId = null;
                                    });

                                    // 3. XỬ LÝ KHI THẢ TAY MÀ KHÔNG THÀNH CÔNG (THẢ TẠI CHỖ HOẶC RA NGOÀI)
                                    if (!_didSwap) {
                                      final renderBox =
                                          _stackKey.currentContext
                                                  ?.findRenderObject()
                                              as RenderBox?;
                                      if (renderBox != null) {
                                        // Tính tọa độ cục feedback ảo lúc thả tay so với gốc của Stack
                                        final localDropPos = renderBox
                                            .globalToLocal(details.offset);
                                        // Tính tọa độ chuẩn của ô lưới đáng lẽ mảnh phải nằm ở đó
                                        final slotX =
                                            (piece.currentIndex % gridSize) *
                                            tileWidth;
                                        final slotY =
                                            (piece.currentIndex ~/ gridSize) *
                                            tileHeight;
                                        // Khoảng cách lệch chính là hiệu của 2 tọa độ trên
                                        final deltaOffset =
                                            localDropPos - Offset(slotX, slotY);

                                        setState(() {
                                          // Áp dụng khoảng lệch cho CẢ CỤM đang kéo để tụi nó cùng bay về một lúc
                                          for (final p in board) {
                                            if (p.groupId == piece.groupId) {
                                              _snapBackOffsets[p.id] =
                                                  deltaOffset;
                                            }
                                          }
                                        });
                                      }
                                    }
                                  },
                                  feedback: _buildGroupFeedback(
                                    piece,
                                    tileWidth,
                                  ),
                                  child: Opacity(
                                    opacity: isPartOfDraggingGroup ? 0.3 : 1.0,
                                    child: tileContent,
                                  ),
                                );
                              },
                            );
                          }

                          // ---------------------------------------------------------
                          // [ANIMATION SWAP]: AnimatedPositioned
                          // ---------------------------------------------------------
                          return AnimatedPositioned(
                            // ValueKey(piece.id) để biết mảnh nào là mảnh nào dù mảng board có xáo trộn.
                            key: ValueKey(piece.id),
                            duration: const Duration(
                              milliseconds: 450,
                            ), // Tốc độ bay lướt
                            curve: Curves
                                .easeOutCubic, // Gia tốc: bay nhanh ở đầu, phanh mượt ở cuối
                            // Tọa độ tính toán vị trí "đích đến" hiện tại của mảnh
                            left: (index % gridSize) * tileWidth,
                            top: (index ~/ gridSize) * tileHeight,
                            width: tileWidth,
                            height: tileHeight,
                            child: currentWidget,
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          Container(color: Colors.blue, height: 100),
        ],
      ),
    );
  }
}
