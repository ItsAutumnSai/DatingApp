import 'package:datingapp/data/model/user_registration_data.dart';
import 'package:datingapp/presentation/registration/opening_move_register_page.dart';
import 'package:flutter/material.dart';

class BioRegisterPage extends StatefulWidget {
  final UserRegistrationData registrationData;

  const BioRegisterPage({super.key, required this.registrationData});

  @override
  State<BioRegisterPage> createState() => _BioRegisterPageState();
}

class _BioRegisterPageState extends State<BioRegisterPage> {
  final TextEditingController _bioController = TextEditingController();

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
                "Bio",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Tell us about yourself",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _bioController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "I like long walks on the beach...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Save Bio (Can be empty if we decide so, but usually bio is good to have)
                    // Let's assume it can be empty or we force min length. User didn't specify.
                    widget.registrationData.bio = _bioController.text;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OpeningMoveRegisterPage(
                          registrationData: widget.registrationData,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.redAccent,
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
