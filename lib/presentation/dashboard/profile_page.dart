import 'package:datingapp/data/model/gender_model.dart';
import 'package:datingapp/data/model/hobby_model.dart';
import 'package:datingapp/data/model/user_session.dart';
import 'package:datingapp/data/repository/auth_repository.dart';
import 'package:datingapp/data/service/httpservice.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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
      final appDir = await getApplicationDocumentsDirectory();
      final directory = Directory('${appDir.path}/static/uploads');
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

      // Wait a bit to let Image.network (UI) have priority on the server
      await Future.delayed(const Duration(seconds: 2));

      http.Response? response;
      int attempts = 0;
      while (attempts < 3) {
        try {
          attempts++;
          print('Attempt $attempts to download image...');
          // Use Connection: Keep-Alive as requested
          response = await http
              .get(url, headers: {'Connection': 'Keep-Alive'})
              .timeout(
                const Duration(seconds: 20),
                onTimeout: () {
                  throw Exception('Connection timed out');
                },
              );

          if (response.statusCode == 200) {
            break; // Success
          }
        } catch (e) {
          print('Attempt $attempts failed: $e');
          if (attempts == 3) rethrow;
          await Future.delayed(Duration(seconds: 1)); // Wait before retry
        }
      }

      print('Response status: ${response?.statusCode}');
      if (response != null) {
        print('Response body length: ${response.bodyBytes.length}');
      }

      if (response != null && response.statusCode == 200) {
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
        print('Failed to download image after $attempts attempts');
        if (response != null) {
          print('Response body: ${response.body}');
        }
      }
    } catch (e, stackTrace) {
      print('CRITICAL ERROR caching image: $e');
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
          child: SizedBox(
            height: 500, // Enforce a height so the Stack doesn't collapse
            width: double.infinity,
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
                            print('ERROR rendering local file: $error');
                            print('Stack trace: $stackTrace');
                            return Center(
                              child: Text("Error loading local file: $error"),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                else if (photo1 != null)
                  // Fallback to network image if local file is not yet ready
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 25.0,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          '${HttpService().baseUrl}/uploads/$photo1',
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(child: Icon(Icons.error));
                          },
                        ),
                      ),
                    ),
                  ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text("Profile"),
                    // Text("Name: $name"),
                    // Text("DOB: $age"),
                    // Text("Bio: $bio"),
                    // Text("Opening Move: $openingMove"),
                    // Text("Gender: $gender"),
                    Text(
                      "Hobbies: $hobbies1, $hobbies2, $hobbies3, $hobbies4, $hobbies5",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
