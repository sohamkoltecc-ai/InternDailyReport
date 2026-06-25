import 'package:flutter/material.dart';

import 'dashboard_page.dart';
import 'project_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
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
            color: Color(0xFF0D47A1),

            child: Column(
              children: [
                const SizedBox(height: 30),

                const Text(
                  "Daily Report",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                Expanded(
                  flex: 9,
                  child: Column(
                    children: [
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

                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Divider(color: Colors.white, height: 3,),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            " Version 1.0",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),

                        ],
                      ),
                          const SizedBox(height: 10),

                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }

  Widget menuButton({
    required IconData icon,
    required String title,
    required int index,
  }) {
    bool selected = selectedIndex == index;

    return ListTile(
      leading: Icon(icon, color: Colors.white),

      title: Text(title, style: const TextStyle(color: Colors.white)),

      tileColor: selected ? Colors.white24 : Colors.transparent,

      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
    );
  }
}
