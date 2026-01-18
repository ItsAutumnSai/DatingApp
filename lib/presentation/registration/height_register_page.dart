import 'package:datingapp/data/model/user_registration_data.dart';
import 'package:datingapp/presentation/registration/hobby_register_page.dart';
import 'package:flutter/material.dart';

class HeightRegisterPage extends StatefulWidget {
  final UserRegistrationData registrationData;

  const HeightRegisterPage({super.key, required this.registrationData});

  @override
  State<HeightRegisterPage> createState() => _HeightRegisterPageState();
}

class _HeightRegisterPageState extends State<HeightRegisterPage> {
  int _selectedHeight = 170; // Default
  final FixedExtentScrollController _controller = FixedExtentScrollController(
    initialItem: 70,
  ); // 170 - 100 = 70

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
                "Height",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text("How tall are you?", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 50),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "$_selectedHeight",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      "cm",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Indicator
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.redAccent, width: 2),
                          bottom: BorderSide(color: Colors.redAccent, width: 2),
                        ),
                      ),
                    ),
                    ListWheelScrollView.useDelegate(
                      controller: _controller,
                      itemExtent: 50,
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedHeight = 100 + index;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 151, // 100 to 250
                        builder: (context, index) {
                          return Center(
                            child: Text(
                              "${100 + index}",
                              style: TextStyle(
                                fontSize: 24,
                                color: _selectedHeight == (100 + index)
                                    ? Colors.redAccent
                                    : Colors.grey,
                                fontWeight: _selectedHeight == (100 + index)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.registrationData.height = _selectedHeight;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HobbyRegisterPage(
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
                    'Continue',
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
