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
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            CarouselSlider.builder(
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
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to ${widget.title}!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(logoImageWhite, width: 100, height: 100),
                  SizedBox(height: screenHeight * 0.5),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the next page or perform an action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 75,
                        vertical: 15,
                      ),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the next page or perform an action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 75,
                        vertical: 15,
                      ),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
