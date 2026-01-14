import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class FrontPage extends StatefulWidget {
  final String title;
  FrontPage({super.key, required this.title});

  final List<String> bgImages = [
    'assets/images/indonesiancouple_1.jpg',
    'assets/images/indonesiancouple_2.jpg',
    'assets/images/indonesiancouple_3.jpg',
    'assets/images/indonesiancouple_4.jpg',
  ];
  @override
  State<FrontPage> createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            CarouselSlider.builder(
              itemCount: widget.bgImages.length,
              itemBuilder: (context, index, realIndex) {
                return Container(
                  child: Image.asset(
                    widget.bgImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              },
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: false,
              ),
            ),
            Center(
              child: Text(
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
            ),
          ],
        ),
      ),
    );
  }
}
