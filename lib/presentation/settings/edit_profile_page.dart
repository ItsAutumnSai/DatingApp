import 'package:datingapp/data/model/gender_model.dart';
import 'package:datingapp/data/model/relationship_interest_model.dart';
import 'package:datingapp/data/model/religion_model.dart';
import 'package:datingapp/data/model/hobby_model.dart';
import 'package:datingapp/data/model/user_session.dart';
import 'package:datingapp/data/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _openingMoveController;
  late TextEditingController _heightController;

  // Dropdown values
  late int _gender;
  late int _genderInterest;
  late int _relationshipInterest;
  late int _religion;
  late bool? _isSmoker;
  late bool? _isDrinker;

  // Photos and Hobbies
  final Map<String, String> _photos = {}; // key: 'photo1', value: filename
  final Map<int, bool> _selectedHobbies = {}; // key: hobbyId, value: selected

  @override
  void initState() {
    super.initState();
    final prefs = widget.userData['prefs'] ?? {};

    _nameController = TextEditingController(text: widget.userData['name']);
    _bioController = TextEditingController(text: prefs['bio']);
    _openingMoveController = TextEditingController(text: prefs['openingmove']);

    // Height might be int or double coming from JSON
    _heightController = TextEditingController(
      text: (prefs['height'] ?? 0).toString(),
    );

    _gender = prefs['gender'] ?? 1;
    _genderInterest = prefs['genderinterest'] ?? 1;
    _relationshipInterest = prefs['relationshipinterest'] ?? 1;
    _religion = prefs['religion'] ?? 1;
    _isSmoker = prefs['is_smoke'];
    _isSmoker = prefs['is_smoke'];
    _isDrinker = prefs['is_drink'];

    // Init Photos
    if (widget.userData['photos'] != null) {
      final photosMap = widget.userData['photos'] as Map<String, dynamic>;
      photosMap.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          _photos[key] = value.toString();
        }
      });
    }

    // Init Hobbies
    // Assuming backend returns hobbies as Map<String, int> or List<int>
    // Based on 'AuthRepository.registerUser', it sends hobbies map.
    // Based on 'getUserProfile', we need to see how it returns.
    // Assuming 'hobbies' key in userData contains map {'hobby1': 1, ...} like registration
    if (widget.userData['hobbies'] != null) {
      final hobbiesData = widget.userData['hobbies'];
      if (hobbiesData is Map) {
        hobbiesData.forEach((k, v) {
          if (v is int) _selectedHobbies[v] = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _openingMoveController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  bool _isPickingImage = false;

  Future<void> _pickImage(String key) async {
    if (_isPickingImage) return;

    // 1. Ask for Source
    ImageSource? source;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.blueAccent,
                ),
                title: const Text('Gallery'),
                onTap: () {
                  source = ImageSource.gallery;
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
                title: const Text('Camera'),
                onTap: () {
                  source = ImageSource.camera;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source!);

      if (pickedFile != null) {
        if (mounted) setState(() => _isLoading = true);
        try {
          final file = File(pickedFile.path);
          final filename = await _authRepository.uploadPhoto(file);
          if (filename != null) {
            if (mounted) {
              setState(() {
                _photos[key] = filename;
              });
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      // Handle picker errors specifically
      debugPrint("Image picker error: $e");
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _removeImage(String key) {
    setState(() {
      _photos.remove(key);
    });
  }

  void _toggleHobby(int id) {
    setState(() {
      if (_selectedHobbies.containsKey(id)) {
        _selectedHobbies.remove(id);
      } else {
        if (_selectedHobbies.length < 5) {
          _selectedHobbies[id] = true;
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Max 5 hobbies")));
        }
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = UserSession().userId!;

      // Construct update payload
      // According to registerUser, standard structure.
      // We will send a map that the backend expects.
      // Assuming backend accepts partial updates or we send relevant fields.

      final Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'prefs': {
          'bio': _bioController.text.trim(),
          'openingmove': _openingMoveController.text.trim(),
          'height': int.tryParse(_heightController.text) ?? 0,
          'gender': _gender,
          'genderinterest': _genderInterest,
          'relationshipinterest': _relationshipInterest,
          'religion': _religion,
          'is_smoke': _isSmoker,
          'is_drink': _isDrinker,
          'latitude': widget.userData['latitude'], // Keep existing
          'longitude': widget.userData['longitude'], // Keep existing
        },
        'photos': _photos,
        'hobbies': _selectedHobbies.keys.fold<Map<String, int>>({}, (map, id) {
          map['hobby${map.length + 1}'] = id;
          return map;
        }),
      };

      // Add hobbies if we had UI for them, but for now filtering them out or keeping existing
      // Ideally we should pass hobbies too if the backend replaces the entire object.
      // For now, let's assume we just update prefs and basic info.
      // If backend requires full object, we might need to merge.

      await _authRepository.updateUser(userId, updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.of(context).pop(true); // Return true to signal refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.redAccent,
                    ),
                  )
                : const Icon(Icons.check, color: Colors.blue),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Basic Info"),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Photos"),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final key = 'photo${index + 1}';
                    final hasPhoto = _photos.containsKey(key);
                    return GestureDetector(
                      onTap: () => hasPhoto ? null : _pickImage(key),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                          image: hasPhoto
                              ? DecorationImage(
                                  image: NetworkImage(
                                    "http://127.0.0.1:5000/static/uploads/${_photos[key]}",
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: Stack(
                          children: [
                            if (!hasPhoto)
                              const Center(
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey,
                                ),
                              ),
                            if (hasPhoto)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => _removeImage(key),
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 10,
                                    child: Icon(
                                      Icons.close,
                                      size: 15,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("About Me"),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _openingMoveController,
                decoration: const InputDecoration(labelText: 'Opening Move'),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Details"),
              DropdownButtonFormField<int>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: [1, 2, 3]
                    .map(
                      (id) => DropdownMenuItem(
                        value: id,
                        child: Text(GenderModel.getLabel(id)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _gender = v!),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _religion,
                decoration: const InputDecoration(labelText: 'Religion'),
                items: [1, 2, 3, 4, 5, 6, 7, 8]
                    .map(
                      (id) => DropdownMenuItem(
                        value: id,
                        child: Text(ReligionModel.getLabel(id)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _religion = v!),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Lifestyle"),
              DropdownButtonFormField<bool?>(
                value: _isSmoker,
                decoration: const InputDecoration(labelText: 'Smoking'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Unknown')),
                  DropdownMenuItem(value: true, child: Text('Yes')),
                  DropdownMenuItem(value: false, child: Text('No')),
                ],
                onChanged: (v) => setState(() => _isSmoker = v),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<bool?>(
                value: _isDrinker,
                decoration: const InputDecoration(labelText: 'Drinking'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Unknown')),
                  DropdownMenuItem(value: true, child: Text('Yes')),
                  DropdownMenuItem(value: false, child: Text('No')),
                ],
                onChanged: (v) => setState(() => _isDrinker = v),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Looking For"),
              DropdownButtonFormField<int>(
                value: _genderInterest,
                decoration: const InputDecoration(labelText: 'Interested In'),
                items: [1, 2, 3, 4]
                    .map(
                      (id) => DropdownMenuItem(
                        value: id,
                        child: Text(GenderModel.getLabel(id)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _genderInterest = v!),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _relationshipInterest,
                decoration: const InputDecoration(labelText: 'Relationship'),
                items: [1, 2, 3, 4, 5, 6]
                    .map(
                      (id) => DropdownMenuItem(
                        value: id,
                        child: Text(RelationshipInterestModel.getLabel(id)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _relationshipInterest = v!),
              ),

              const SizedBox(height: 20),

              _buildSectionTitle("Hobbies (Max 5)"),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: HobbyModel.hobbies.entries.map((entry) {
                  final isSelected = _selectedHobbies.containsKey(entry.key);
                  return FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (_) => _toggleHobby(entry.key),
                    selectedColor: Colors.redAccent.withOpacity(0.2),
                    checkmarkColor: Colors.redAccent,
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
