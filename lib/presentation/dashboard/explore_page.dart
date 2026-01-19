import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:datingapp/data/service/httpservice.dart';
import 'package:datingapp/presentation/dashboard/chat_page.dart';
import 'package:datingapp/data/model/user_session.dart';
import 'package:datingapp/data/repository/auth_repository.dart';
import 'package:datingapp/presentation/widgets/profile_card.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final AuthRepository _authRepository = AuthRepository();
  final CardSwiperController _controller = CardSwiperController();
  List<dynamic> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = UserSession().userId;
      if (userId == null) {
        throw Exception("User not logged in");
      }
      final users = await _authRepository.getExploreUsers(userId);
      setState(() {
        _users = users;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) async {
    final user = _users[previousIndex];

    if (direction == CardSwiperDirection.right) {
      // Like
      try {
        final currentUserId = UserSession().userId;
        if (currentUserId != null) {
          final response = await _authRepository.likeUser(
            user['id'],
            currentUserId,
          );
          debugPrint("Liked user ${user['id']}: $response");

          if (response['match'] == true) {
            if (context.mounted) {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("It's a Match!"),
                  content: Text(
                    "You and ${user['name'] ?? 'someone'} liked each other.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Keep Swiping"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close dialog
                        // Start Chat
                        try {
                          await _authRepository.startChat(
                            currentUserId,
                            user['id'],
                          );
                          if (context.mounted) {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      partnerId: user['id'],
                                      partnerName: user['name'] ?? 'Unknown',
                                      partnerPhoto:
                                          user['photos']?['photo1'] != null
                                          ? '${HttpService().baseUrl}/uploads/${user['photos']['photo1']}'
                                          : null,
                                    ),
                                  ),
                                )
                                .then((_) => _loadUsers()); // Refresh on return
                          }
                        } catch (e) {
                          debugPrint("Error starting chat: $e");
                        }
                      },
                      child: const Text(
                        "Chat Now",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        }
      } catch (e) {
        debugPrint("Error liking user: $e");
        // Optionally show snackbar but don't block swipe
      }
    } else if (direction == CardSwiperDirection.left) {
      // Dislike (Pass)
      debugPrint("Passed user ${user['id']}");
    }

    // Return true to allow the swipe
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error: $_errorMessage"),
              ElevatedButton(onPressed: _loadUsers, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    if (_users.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_border, size: 60, color: Colors.grey),
              const SizedBox(height: 10),
              const Text(
                "No more profiles",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CardSwiper(
                controller: _controller,
                cardsCount: _users.length,
                onSwipe: _onSwipe,
                numberOfCardsDisplayed: _users.length < 2 ? _users.length : 2,
                backCardOffset: const Offset(40, 40),
                padding: const EdgeInsets.all(24.0),
                cardBuilder:
                    (
                      context,
                      index,
                      horizontalOffsetPercentage,
                      verticalOffsetPercentage,
                    ) {
                      final user = _users[index];
                      // Transform user map to what ProfileCard expects
                      // ProfileCard expects arguments: name, age, bio, images, etc.
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ProfileCard(
                          userData: user,
                          isCurrentUser: false,
                        ),
                      );
                    },
              ),
            ),
            // Controls
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton.filled(
                    onPressed: () =>
                        _controller.swipe(CardSwiperDirection.left),
                    icon: const Icon(Icons.close, size: 30),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.red,
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () =>
                        _controller.swipe(CardSwiperDirection.right),
                    icon: const Icon(Icons.favorite, size: 30),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
