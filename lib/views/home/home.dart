import 'package:fittracker/services/auth.dart';
import 'package:fittracker/theme/colors.dart';
import 'package:fittracker/views/activity/acitvity_list.dart';
import 'package:fittracker/views/home/recent_avtivity_list.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int myIndex = 0;

  final AuthService _auth = AuthService();
  final PageController _pageController = PageController();

  List<Widget> pages = [
    RecentActivitiesList(),
    AcitvityList(),
    const Center(child: Text('Statistics')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitTracker'),
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.person),
            label: const Text('Logout'),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
       body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            myIndex = index;
          });
        },
        children: pages),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.secondary,
        unselectedItemColor: AppColors.background,
        selectedItemColor: AppColors.text,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
        ],
        currentIndex: myIndex,
        onTap: (index) {
        setState(() {
          myIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      ),
    );
  }
}