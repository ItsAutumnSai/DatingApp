import 'dart:io';
import 'package:datingapp/data/service/httpservice.dart';
import 'package:datingapp/data/model/user_registration_data.dart';
import 'package:datingapp/presentation/registration/religion_register_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotosRegisterPage extends StatefulWidget {
  final UserRegistrationData registrationData;

  const PhotosRegisterPage({super.key, required this.registrationData});

  @override
  State<PhotosRegisterPage> createState() => _PhotosRegisterPageState();
}

class _PhotosRegisterPageState extends State<PhotosRegisterPage> {
  final List<XFile> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          if (_selectedPhotos.length < 5) {
            _selectedPhotos.add(image);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You can only upload 5 photos')),
            );
          }
        });
      }
    } catch (e) {
      // Handle permission or other errors
      print("Image pick error: $e");
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Photos",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text("Add 2 to 5 photos", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _selectedPhotos.length + 1,
                  itemBuilder: (context, index) {
                    // Add Button
                    if (index == _selectedPhotos.length) {
                      if (_selectedPhotos.length < 5) {
                        return GestureDetector(
                          onTap: () => _showImageSourceActionSheet(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.redAccent,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.redAccent,
                              size: 40,
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }

                    // Photo Item
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(
                                File(_selectedPhotos[index].path),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => _removePhoto(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedPhotos.length < 2 || _isLoading)
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            List<String> uploadedFilenames = [];
                            final httpService = HttpService();

                            for (var photo in _selectedPhotos) {
                              final filename = await httpService.uploadImage(
                                File(photo.path),
                              );
                              if (filename != null) {
                                uploadedFilenames.add(filename);
                              }
                            }

                            widget.registrationData.photos = uploadedFilenames;

                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReligionRegisterPage(
                                    registrationData: widget.registrationData,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to upload photos: $e'),
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.redAccent,
                          ),
                        )
                      : Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 18,
                            color: _selectedPhotos.length < 2
                                ? Colors.grey
                                : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
