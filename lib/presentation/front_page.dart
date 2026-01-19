import 'package:datingapp/presentation/registration/phone_register_page.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class FrontPage extends StatefulWidget {
  final String title;
  const FrontPage({super.key, required this.title});

  @override
  State<FrontPage> createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  final List<String> bgImages = [
    'assets/images/indonesiancouple_1.jpg',
    'assets/images/indonesiancouple_2.jpg',
    'assets/images/indonesiancouple_3.jpg',
    'assets/images/indonesiancouple_4.jpg',
  ];
  final String logoImageWhite = 'assets/images/Logo_White.png';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(logoImageWhite, width: 40, height: 40),
            const SizedBox(width: 10),
            Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CarouselSlider.builder(
              itemCount: bgImages.length,
              itemBuilder: (context, index, realIndex) {
                return Image.asset(
                  bgImages[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                autoPlayAnimationDuration: Duration(milliseconds: 1200),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: false,
                scrollPhysics: const NeverScrollableScrollPhysics(),
                pauseAutoPlayOnTouch: false,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PhoneRegisterPage(alreadyHaveAccount: true),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: Colors.white70,
                        minimumSize: const Size(double.infinity, 50),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: const Text(
                        'I already have an account',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PhoneRegisterPage(alreadyHaveAccount: false),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: const Text(
                        'I don\'t have an account',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        "Disclaimer",
                        style: TextStyle(fontSize: 20),
                      ),
                      content: const Text(
                        "Please respect everyone. Sexual harassment and explicit content are strictly prohibited.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  "Disclaimer",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ],
      ),
    );
  }
}
