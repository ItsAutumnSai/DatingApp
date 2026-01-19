import 'package:datingapp/presentation/dashboard/chat_list_page.dart';
import 'package:datingapp/presentation/dashboard/likesyou_page.dart';
import 'package:datingapp/presentation/dashboard/profile_page.dart';
import 'package:datingapp/presentation/dashboard/explore_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 1; // Start at Swipe Page by default

  final List<Widget> _pages = [
    const ProfilePage(),
    const ExplorePage(),
    const LikesYouPage(),
    const ChatListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      backgroundColor: Colors.white,
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: const Color.fromARGB(255, 255, 0, 0).withAlpha(10),
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 38,
          items: [
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Icon(Icons.person),
              ),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SvgPicture.asset(
                  'assets/images/Logo_Vector.svg',
                  height: 32,
                  width: 32,
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 1 ? Colors.redAccent : Colors.grey[400]!,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              label: 'Explore',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Icon(Icons.favorite),
              ),
              label: 'LikesYou',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Icon(Icons.chat_bubble_rounded),
              ),
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
}
