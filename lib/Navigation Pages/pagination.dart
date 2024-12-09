import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:time_management/Navigation%20Pages/profile/profile.dart';
import 'package:time_management/Navigation%20Pages/home.dart';
import 'package:time_management/Navigation%20Pages/work_archieves.dart';

class PagesController extends StatefulWidget {
  int? indexPage;
  PagesController({super.key, this.indexPage});

  @override
  State<PagesController> createState() => _PagesControllerState();
}

class _PagesControllerState extends State<PagesController> {
  final PageController _pageController = PageController();
  List<Widget> items = [
    const Icon(Icons.home_outlined, size: 30),
    const Icon(Icons.list, size: 30),
    const Icon(Icons.person, size: 30),
  ];
  @override
  void initState() {
    super.initState();
    jumpPageAfterLogin();
  }

  jumpPageAfterLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.indexPage != null) {
        _pageController.jumpToPage(widget.indexPage!);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        // physics: const NeverScrollableScrollPhysics(),
        children: const [
          StartTimePage(),
          WorkArchieves(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        color: Theme.of(context).colorScheme.primary,
        items: items,
        index: widget.indexPage ?? 0,
        onTap: (value) {
          _pageController.jumpToPage(value);
        },
      ),
    );
  }
}
