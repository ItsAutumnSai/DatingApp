import 'package:datingapp/data/model/gender_model.dart';
import 'package:datingapp/data/model/hobby_model.dart';
import 'package:datingapp/data/model/user_session.dart';
import 'package:datingapp/data/repository/auth_repository.dart';
import 'package:datingapp/data/service/httpservice.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

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
  File? _profileImageFile;

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

      if (_userData != null &&
          _userData!['photos'] != null &&
          _userData!['photos']['photo1'] != null) {
        _cacheImage(_userData!['photos']['photo1']);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cacheImage(String filename) async {
    try {
      print('Starting _cacheImage for: $filename');
      final directory = Directory('static/uploads');
      print('Directory path: ${directory.path}');

      if (!await directory.exists()) {
        print('Directory does not exist, creating...');
        await directory.create(recursive: true);
        print('Directory created successfully');
      } else {
        print('Directory already exists');
      }

      final file = File('${directory.path}/$filename');
      print('Full file path: ${file.path}');

      if (await file.exists()) {
        print('File already exists locally, using cached version');
        setState(() {
          _profileImageFile = file;
        });
        return;
      }

      // Download if not exists
      final url = Uri.parse('${HttpService().baseUrl}/uploads/$filename');
      print('Downloading from: $url');
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body length: ${response.bodyBytes.length}');

      if (response.statusCode == 200) {
        print('Writing ${response.bodyBytes.length} bytes to file...');
        await file.writeAsBytes(response.bodyBytes);
        print('File written successfully');

        if (mounted) {
          setState(() {
            _profileImageFile = file;
          });
          print('State updated with profile image file');
        }
      } else {
        print('Failed to download image: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error caching image: $e');
      print('Stack trace: $stackTrace');
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
    final photo1 = _userData!['photos']?['photo1'] ?? null;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(
            children: [
              if (_profileImageFile != null)
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 25.0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.file(
                        _profileImageFile!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text("Error loading local file"),
                          );
                        },
                      ),
                    ),
                  ),
                )
              else if (photo1 != null)
                // Fallback to network or loading while caching
                Positioned.fill(
                  child: Center(child: CircularProgressIndicator()),
                ),

              Column(
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
            ],
          ),
        ),
      ),
    );
  }
}
