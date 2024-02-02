import 'dart:developer';

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:managing_app/pages/addClients.dart';
import 'package:managing_app/pages/payement.dart';
import 'package:managing_app/pages/addAgentForm.dart';
import 'package:managing_app/pages/agentList.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Controller to handle PageView and also handles initial page
  final _pageController = PageController(initialPage: 0);

  /// Controller to handle bottom nav bar and also handles initial page
  final _controller = NotchBottomBarController(index: 0);

  int maxCount = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// widget list
  final List<Widget> bottomBarPages = [
    AgentList(),
    const Payements(),
    const AddClients(),
    const AddAgentForm(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageView(
        controller: _pageController,
        children: List.generate(
            bottomBarPages.length, (index) => bottomBarPages[index]),
      ),
      extendBody: true,
      bottomNavigationBar: (bottomBarPages.length <= maxCount)
          ? AnimatedNotchBottomBar(
              /// Provide NotchBottomBarController
              notchBottomBarController: _controller,
              color: Color(0xFF1F1F1F),
              showLabel: false,
              notchColor: const Color(0xE42C6CB5),

              /// restart app if you change removeMargins
              removeMargins: false,
              bottomBarWidth: 500,
              durationInMilliSeconds: 300,
              bottomBarItems: const [
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.view_agenda_rounded,
                    color: Color(0xE42C6CB5),
                  ),
                  activeItem: Icon(
                    Icons.view_agenda_rounded,
                    color: Color(0xFFFFFFFF),
                  ),
                  itemLabel: 'AgentsList',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.money,
                    color: Color(0xE42C6CB5),
                  ),
                  activeItem: Icon(
                    Icons.money,
                    color: Color(0xFFFFFFFF),
                  ),
                  itemLabel: 'Payements',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.add_business,
                    color: Color(0xE42C6CB5),
                  ),
                  activeItem: Icon(
                    Icons.add_business,
                    color: Color(0xFFFFFFFF),
                  ),
                  itemLabel: 'Clients',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.add,
                    color: Color(0xE42C6CB5),
                  ),
                  activeItem: Icon(
                    Icons.add,
                    color: Color(0xFFFFFFFF),
                  ),
                  itemLabel: 'AddAgents',
                ),
              ],
              onTap: (index) {
                /// perform action on tab change and to update pages you can update pages without pages
                log('current selected index $index');
                _pageController.jumpToPage(index);
              },
            )
          : null,
    );
  }
}
