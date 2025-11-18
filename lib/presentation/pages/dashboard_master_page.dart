import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardMasterPage extends StatefulWidget {
  const DashboardMasterPage({super.key});

  @override
  State<DashboardMasterPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardMasterPage> {
  int _currentIndex = 0;

  final int totalUser1 = 14;
  final int totalUser2 = 14;

  @override
  Widget build(BuildContext context) {
    final padding = 20.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),

              _buildShortcutRow(),

              const SizedBox(height: 26),

              _buildStatCard(
                icon: Icons.calendar_month,
                title: 'Total User',
                value: totalUser1.toString(),
                backgroundColor: const Color(0xFF0E8A7E),
                iconColor: Colors.white,
              ),

              const SizedBox(height: 18),

              _buildStatCard(
                icon: Icons.group,
                title: 'Total User',
                value: totalUser2.toString(),
                backgroundColor: const Color(0xFF0B8A44),
                iconColor: Colors.white,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // HEADER ---------------------------------------------------
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF133B67),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Hallo, Master!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Bagaimana kabarmu hari ini?',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: const DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                'https://images.unsplash.com/photo-1527980965255-d3b416303d12',
              ),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
            ],
          ),
        ),
      ],
    );
  }

  // SHORTCUT ROW --------------------------------------------
  Widget _buildShortcutRow() {
    final shortcuts = [
      {
        'label': 'user',
        'icon': Icons.manage_accounts,
        'bg': const Color(0xFF183B67),
        'route': '/users',
      },
      {
        'label': 'rapat',
        'icon': Icons.calendar_month,
        'bg': const Color(0xFF0FBF49),
        'route': '/home',
      },
      {
        'label': 'divisi',
        'icon': Icons.business,
        'bg': const Color(0xFF183B67),
        'route': '/divisions',
      },
      {
        'label': 'profile',
        'icon': Icons.person,
        'bg': const Color(0xFF183B67),
        'route': '/home',
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: shortcuts.map((item) {
        return GestureDetector(
          onTap: () => Get.toNamed(item['route'] as String),
          child: Column(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: item['bg'] as Color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    item['icon'] as IconData,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['label'] as String,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      height: 120,
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, size: 46, color: iconColor)),
          ),
          const SizedBox(width: 18),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // BOTTOM NAV ----------------------------------------------
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.teal.shade700,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() => _currentIndex = index);

        switch (index) {
          case 0:
            Get.offNamed('/master-dashboard');
            break;
          case 1:
            Get.offNamed('/users');
            break;
          case 2:
            Get.offNamed('/divisions');
            break;
          case 3:
            Get.offNamed('/home');
            break;
          case 4:
            Get.offNamed('/home');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: "Scan",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.business), label: "Divisi"),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: "Riwayat",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
