import 'package:flutter/material.dart';

import '../model/collection_model.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final collections = [
    CollectionModel(image: 'assets/italy.jpg', title: '1-25', isUnlocked: true),
    CollectionModel(title: '26-50', isUnlocked: false),
    CollectionModel(title: '51-75', isUnlocked: false),
    CollectionModel(title: '76-100', isUnlocked: false),
    CollectionModel(title: '101-125', isUnlocked: false),
    CollectionModel(title: '126-150', isUnlocked: false),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.png', // ảnh nền của bạn
              fit: BoxFit.cover,
            ),
          ),
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
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF056E45),
                              size: 40,
                            ),
                          ),
                        ),

                        const Text(
                          'Collection',
                          style: TextStyle(
                            color: Color(0xFF056E45),
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      itemCount: collections.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.65,
                          ),
                      itemBuilder: (context, index) {
                        final item = collections[index];

                        return GestureDetector(
                          onTap: item.isUnlocked
                              ? () {
                                  // xử lý chọn collection
                                }
                              : null,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF748A84),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.green.shade900,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: item.isUnlocked
                                      ? Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.asset(
                                              item.image!,
                                              fit: BoxFit.cover,
                                            ),

                                            // ⭐ overlay tối nhẹ
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.black.withOpacity(
                                                      0.0,
                                                    ),
                                                    Colors.black.withOpacity(
                                                      0.4,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            Positioned(
                                              top: 12,
                                              left: 12,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'Italy',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Center(
                                          child: Icon(
                                            Icons.lock,
                                            color: Colors.white,
                                            size: 70,
                                          ),
                                        ),
                                ),
                              ),

                              Positioned(
                                bottom: 0,
                                left: 40,
                                right: 40,
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade900,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
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
