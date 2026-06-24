import 'package:flutter/material.dart';

import 'dashboard_page.dart';
import 'project_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const DashBoardPage(),
    const ProjectsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [

          // Sidebar
          Container(
            width: 250,
            color: Colors.blue,

            child: Column(
              children: [

                const SizedBox(height: 30),

                const Text(
                  "Daily Report",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                menuButton(
                  icon: Icons.dashboard,
                  title: "Dashboard",
                  index: 0,
                ),

                menuButton(
                  icon: Icons.folder,
                  title: "Projects",
                  index: 1,
                ),

                menuButton(
                  icon: Icons.settings,
                  title: "Settings",
                  index: 2,
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: pages[selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget menuButton({
    required IconData icon,
    required String title,
    required int index,
  }) {
    bool selected =
        selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),

      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),

      tileColor: selected
          ? Colors.white24
          : Colors.transparent,

      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
    );
  }
}