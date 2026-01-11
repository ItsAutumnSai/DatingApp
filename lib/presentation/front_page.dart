import 'package:flutter/material.dart';

class FrontPage extends StatefulWidget {
  final String title;
  const FrontPage({super.key, required this.title});
  @override
  State<FrontPage> createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Welcome to ${widget.title}!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
