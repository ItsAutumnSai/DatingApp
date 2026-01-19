import 'package:flutter/material.dart';
import 'package:datingapp/data/model/user_session.dart';
import 'package:datingapp/data/repository/auth_repository.dart';
import 'package:datingapp/data/service/httpservice.dart';

class LikesYouPage extends StatefulWidget {
  const LikesYouPage({super.key});

  @override
  State<LikesYouPage> createState() => _LikesYouPageState();
}

class _LikesYouPageState extends State<LikesYouPage> {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _likedMeUsers = [];
  List<dynamic> _myLikesUsers = [];

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = UserSession().userId;
      if (userId == null) throw Exception("User not logged in");

      final matches = await _authRepository.getMatches(userId);
      setState(() {
        _likedMeUsers = matches['liked_me'] ?? [];
        _myLikesUsers = matches['my_likes'] ?? [];
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "PairMe",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: false,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            labelColor: Colors.redAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.redAccent,
            tabs: [
              Tab(text: "Likes You"),
              Tab(text: "You Liked"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              )
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: $_errorMessage"),
                    ElevatedButton(
                      onPressed: _loadMatches,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              )
            : TabBarView(
                children: [
                  _buildList(_likedMeUsers),
                  _buildList(_myLikesUsers),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<dynamic> users) {
    if (users.isEmpty) {
      return const Center(
        child: Text(
          "No matches yet",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final photoUrl = user['photos']?['photo1'] != null
            ? '${HttpService().baseUrl}/uploads/${user['photos']['photo1']}'
            : null;

        final name = user['name'] ?? 'Unknown';
        final age = _calculateAge(user['dateofbirth']);

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                image: photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(photoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Text Overlay (Name, Age)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$name, $age",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (photoUrl == null)
                    const Center(
                      child: Icon(Icons.person, size: 60, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _calculateAge(String? dobString) {
    if (dobString == null) return "25"; // Default
    try {
      DateTime dob = DateTime.parse(dobString);
      DateTime now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return "25";
    }
  }
}
