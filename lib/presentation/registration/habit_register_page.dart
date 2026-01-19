import 'package:datingapp/data/model/user_registration_data.dart';
import 'package:datingapp/presentation/registration/photos_register_page.dart';
import 'package:flutter/material.dart';

class HabitRegisterPage extends StatefulWidget {
  final UserRegistrationData registrationData;

  const HabitRegisterPage({super.key, required this.registrationData});

  @override
  State<HabitRegisterPage> createState() => _HabitRegisterPageState();
}

class _HabitRegisterPageState extends State<HabitRegisterPage> {
  bool? _isDrinker;
  bool? _isSmoker;

  Widget _buildYesNoOption(
    String title,
    bool? value,
    Function(bool) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: value == true ? Colors.redAccent : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: value == true
                          ? Colors.redAccent
                          : Colors.grey[300]!,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Yes",
                    style: TextStyle(
                      fontSize: 16,
                      color: value == true ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: value == false ? Colors.redAccent : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: value == false
                          ? Colors.redAccent
                          : Colors.grey[300]!,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "No",
                    style: TextStyle(
                      fontSize: 16,
                      color: value == false ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
                "Lifestyle",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Do you drink or smoke?",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 50),
              _buildYesNoOption("Do you drink?", _isDrinker, (val) {
                setState(() {
                  _isDrinker = val;
                });
              }),
              const SizedBox(height: 40),
              _buildYesNoOption("Do you smoke?", _isSmoker, (val) {
                setState(() {
                  _isSmoker = val;
                });
              }),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isDrinker == null || _isSmoker == null)
                      ? null
                      : () {
                          widget.registrationData.isDrinker = _isDrinker;
                          widget.registrationData.isSmoker = _isSmoker;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotosRegisterPage(
                                registrationData: widget.registrationData,
                              ),
                            ),
                          );
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
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 18,
                      color: (_isDrinker == null || _isSmoker == null)
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
