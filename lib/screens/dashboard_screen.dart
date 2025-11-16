import 'dart:ui';
import 'package:empower_ananya/screens/tabs/colleges_tab.dart';
import 'package:empower_ananya/screens/tabs/engagement_tab.dart';
import 'package:empower_ananya/screens/tabs/metrics_tab.dart';
import 'package:empower_ananya/screens/tabs/profiles_tab.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  final List<Widget> _tabs = [
    const MetricsTab(),
    const CollegesTab(),
    const EngagementTab(),
    const ProfilesTab(),
  ];

  final List<String> _tabTitles = [
    'Dashboard',
    'Colleges & Programs',
    'Engagement Network',
    'Scholar Profiles',
  ];

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 30))
          ..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body to go behind the bottom navigation bar
      appBar: AppBar(
        title: Text(_tabTitles[_currentIndex]),
        centerTitle: true,
        backgroundColor: Colors.black.withAlpha(51), // Semi-transparent AppBar
      ),
      body: Stack(
        children: [
          // Animated Gradient Background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      Color(0xFF0052D4),
                      Color(0xFF4364F7),
                      Color(0xFF65C7F7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    transform: GradientRotation(
                        _animationController.value * 2 * 3.1415),
                  ),
                ),
              );
            },
          ),
          // Tab Content
          SafeArea(
            bottom: false, // Allow content to go to the very bottom
            child: IndexedStack(
              index: _currentIndex,
              children: _tabs,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildGlassBottomNavBar(),
    );
  }

  Widget _buildGlassBottomNavBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.school_rounded), label: 'Colleges'),
            BottomNavigationBarItem(
                icon: Icon(Icons.group_work_rounded), label: 'Network'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Profiles'),
          ],
        ),
      ),
    );
  }
}
