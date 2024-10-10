import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:time_management/Navigation%20Pages/infos.dart';
import 'package:time_management/Navigation%20Pages/start.dart';

class PagesController extends StatefulWidget {
  const PagesController({super.key});

  @override
  State<PagesController> createState() => _PagesControllerState();
}

class _PagesControllerState extends State<PagesController> {
  final PageController _pageController = PageController();
  List<Widget> items = [
    const Icon(Icons.home_outlined, size: 30),
    const Icon(Icons.list, size: 30),
    const Icon(Icons.settings, size: 30),
  ];
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          StartTimePage(),
          StartTimePage(),
          InfosPage(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        color: Theme.of(context).colorScheme.primaryContainer,
        items: items,
        index: 0,
        onTap: (value) {
          _pageController.jumpToPage(value);
        },
      ),
    );
  }
}
