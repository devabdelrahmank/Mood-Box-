import 'package:flutter/material.dart';
import 'package:movie_proj/feature/home/home_screen.dart';
import 'package:movie_proj/feature/suggest/suggest_screen.dart';
import 'package:movie_proj/feature/myList/my_list_screen.dart';
import 'package:movie_proj/feature/myFriends/my_friends_screen.dart';
import 'package:movie_proj/feature/profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(onNavigate: _onNavigate);
      case 1:
        return SuggestScreen(onNavigate: _onNavigate);
      case 2:
        return MyListScreen(onNavigate: _onNavigate);
      case 3:
        return MyFriendsScreen(onNavigate: _onNavigate);
      case 4:
        return ProfileScreen(onNavigate: _onNavigate);
      default:
        return HomeScreen(onNavigate: _onNavigate);
    }
  }
}
