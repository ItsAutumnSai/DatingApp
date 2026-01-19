import 'package:datingapp/data/model/gender_model.dart';
import 'package:datingapp/data/model/hobby_model.dart';
import 'package:datingapp/data/model/user_session.dart';
import 'package:datingapp/data/repository/auth_repository.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthRepository _authRepository = AuthRepository();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = UserSession().userId;
    if (userId == null) {
      setState(() {
        _error = "No user logged in";
        _isLoading = false;
      });
      return;
    }

    try {
      final data = await _authRepository.getUserProfile(userId);
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
      );
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    if (_userData == null) {
      return const Scaffold(body: Center(child: Text("No profile data found")));
    }

    final name = _userData!['name'] ?? 'Unknown';
    final age = _userData!['dateofbirth'] ?? 'Unknown';
    final bio = _userData!['prefs']?['bio'] ?? 'No bio';
    final openingMove =
        _userData!['prefs']?['openingmove'] ?? 'No opening move';
    final gender = GenderModel.getLabel(_userData!['prefs']?['gender']);
    final hobbies1 = HobbyModel.getLabel(_userData!['hobbies']?['hobby1']);
    final hobbies2 = HobbyModel.getLabel(_userData!['hobbies']?['hobby2']);
    final hobbies3 = HobbyModel.getLabel(_userData!['hobbies']?['hobby3']);
    final hobbies4 = HobbyModel.getLabel(_userData!['hobbies']?['hobby4']);
    final hobbies5 = HobbyModel.getLabel(_userData!['hobbies']?['hobby5']);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Profile"),
              Text("Name: $name"),
              Text("DOB: $age"),
              Text("Bio: $bio"),
              Text("Opening Move: $openingMove"),
              Text("Gender: $gender"),
              Text(
                "Hobbies: $hobbies1, $hobbies2, $hobbies3, $hobbies4, $hobbies5",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
