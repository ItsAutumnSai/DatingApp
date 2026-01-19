import 'package:datingapp/data/model/religion_model.dart';
import 'package:datingapp/data/model/user_registration_data.dart';
import 'package:datingapp/presentation/registration/bio_register_page.dart';
import 'package:flutter/material.dart';

class ReligionRegisterPage extends StatefulWidget {
  final UserRegistrationData registrationData;

  const ReligionRegisterPage({super.key, required this.registrationData});

  @override
  State<ReligionRegisterPage> createState() => _ReligionRegisterPageState();
}

class _ReligionRegisterPageState extends State<ReligionRegisterPage> {
  int? _selectedReligion;

  Widget _buildOption(int id, String label) {
    final isSelected = _selectedReligion == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReligion = id;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.redAccent : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.redAccent : Colors.black,
              ),
            ),
            if (isSelected) const Icon(Icons.check, color: Colors.redAccent),
          ],
        ),
      ),
    );
  }

  void _proceed() {
    // Optional, so null is fine if skipped (but UI forces selection or "Skip" button if we added one)
    // Here we'll just allow proceed if selected, or maybe add a Skip button.
    // User request said "Optional".

    widget.registrationData.religion = _selectedReligion;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BioRegisterPage(registrationData: widget.registrationData),
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
        actions: [
          TextButton(
            onPressed: _proceed,
            child: const Text(
              "Skip",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Religion",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                "What's your religion? (Optional)",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: ReligionModel.religions.entries
                      .map((entry) => _buildOption(entry.key, entry.value))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedReligion == null ? null : _proceed,
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      color: _selectedReligion == null
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
