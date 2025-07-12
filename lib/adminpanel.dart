import 'package:flutter/material.dart';
import 'firebase services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for FirebaseAuth
import 'login.dart'; // Correct import for LoginPage

// Convert Adminpanel to StatefulWidget for tab switching
class Adminpanel extends StatefulWidget {
  const Adminpanel({super.key});
  @override
  State<Adminpanel> createState() => _AdminpanelState();
}

class _AdminpanelState extends State<Adminpanel> {
  int selectedTab = 0; // 0: Dashboard, 1: Users, 2: Pending Requests

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF008080);
    final Color accentColor = const Color(0xFF4FC3F7);
    final Color backgroundColor = const Color(0xFFF9F9F9);
    final double screenWidth = MediaQuery.of(context).size.width;

    // --- ENHANCED NAVBAR ---
    Widget navBar = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _EnhancedNavTab(
            icon: Icons.dashboard,
            label: 'Dashboard',
            selected: selectedTab == 0,
            onTap: () => setState(() => selectedTab = 0),
          ),
          _EnhancedNavTab(
            icon: Icons.people,
            label: 'Users',
            selected: selectedTab == 1,
            onTap: () => setState(() => selectedTab = 1),
          ),
          _EnhancedNavTab(
            icon: Icons.pending_actions,
            label: 'Pending',
            selected: selectedTab == 2,
            onTap: () => setState(() => selectedTab = 2),
          ),
        ],
      ),
    );

    // --- ENHANCED DASHBOARD CARDS & NAVBAR ---
    // Replace summaryCards with improved, interactive cards
    Widget summaryCards = FutureBuilder(
      future: Future.wait([
        FirebaseFirestore.instance.collection('users').get(),
        FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'teacher').get(),
        FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'student').get(),
        FirebaseFirestore.instance.collection('users').where('approved', isEqualTo: false).get(),
      ]),
      builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final totalUsers = snapshot.data![0].docs.length;
        final totalTeachers = snapshot.data![1].docs.length;
        final totalStudents = snapshot.data![2].docs.length;
        final pendingRequests = snapshot.data![3].docs.length;
        // Enhanced: Cards are bigger, clickable, with hover/scale effect and pointer cursor
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _EnhancedDashboardCard(
                icon: Icons.people,
                title: 'Total Users',
                count: totalUsers,
                color: Colors.teal,
                onTap: () => setState(() => selectedTab = 1), // Go to Users tab
              ),
              _EnhancedDashboardCard(
                icon: Icons.person,
                title: 'Teachers',
                count: totalTeachers,
                color: Colors.blue,
                onTap: () => setState(() => selectedTab = 1),
              ),
              _EnhancedDashboardCard(
                icon: Icons.school,
                title: 'Students',
                count: totalStudents,
                color: Colors.green,
                onTap: () => setState(() => selectedTab = 1),
              ),
              _EnhancedDashboardCard(
                icon: Icons.pending_actions,
                title: 'Pending',
                count: pendingRequests,
                color: Colors.orange,
                highlight: true,
                onTap: () => setState(() => selectedTab = 2), // Go to Pending tab
              ),
            ],
          ),
        );
      },
    );

    Widget dashboardActions = Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome/admin card and action cards only. User management is now only on Users tab.
          Card(
            color: primaryColor,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, color: primaryColor, size: 40),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Welcome, Admin!', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                        SizedBox(height: 8),
                        Text('Manage users, classes, and attendance.', style: TextStyle(color: Colors.white70, fontSize: 17, fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Container(
                width: 7,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Admin Actions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'Poppins',
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.settings, color: accentColor, size: 26),
            ],
          ),
          const SizedBox(height: 18),
          // Use Column for action cards to prevent overflow
          _StylishActionCard(
            icon: Icons.class_,
            title: 'Manage Classes',
            color: accentColor,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageClassesScreen()));
            },
          ),
          const SizedBox(height: 18),
          _StylishActionCard(
            icon: Icons.assignment_turned_in,
            title: 'View Attendance',
            color: accentColor,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewAttendanceScreen()));
            },
          ),
          // Do NOT include userManagement here!
        ],
      ),
    );

    Widget userManagement = Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: accentColor, size: 28),
              const SizedBox(width: 10),
              Text('User Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor, fontFamily: 'Poppins')),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!.docs;
                if (users.isEmpty) {
                  return const Center(child: Text('No users found.', style: TextStyle(fontFamily: 'Poppins')));
                }
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final doc = users[index];
                    final isPending = doc['approved'] == false;
                    final isTeacher = doc['role'] == 'teacher';
                    final isStudent = doc['role'] == 'student';
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      color: isPending ? Colors.orange.withOpacity(0.10) : Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isTeacher ? accentColor : (isStudent ? Colors.green : primaryColor),
                          child: Icon(isTeacher ? Icons.person : (isStudent ? Icons.school : Icons.admin_panel_settings), color: Colors.white),
                        ),
                        title: Text(doc['name'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                        subtitle: Text('${doc['email']}\nRole: ${doc['role']}', style: const TextStyle(fontFamily: 'Poppins')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPending)
                              Switch(
                                value: !isPending, // true if approved, false if pending
                                activeColor: Colors.green,
                                inactiveThumbColor: Colors.red,
                                onChanged: (val) async {
                                  if (val) {
                                    await firebaseService.approveUser(doc.id);
                                    // Show SnackBar after approval
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('User approved!'), duration: Duration(seconds: 2)),
                                      );
                                    }
                                  } else {
                                    await firebaseService.deleteUser(doc.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('User rejected and deleted!'), duration: Duration(seconds: 2)),
                                      );
                                    }
                                  }
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Edit User',
                              onPressed: () async {
                                String updatedName = doc['name'] ?? '';
                                String updatedRole = doc['role'] ?? '';
                                final result = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Edit User'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            decoration: InputDecoration(labelText: 'Name'),
                                            controller: TextEditingController(text: updatedName),
                                            onChanged: (val) => updatedName = val,
                                          ),
                                          DropdownButtonFormField<String>(
                                            value: updatedRole,
                                            items: ['admin', 'teacher', 'student']
                                                .map((role) => DropdownMenuItem(
                                                      value: role,
                                                      child: Text(role[0].toUpperCase() + role.substring(1)),
                                                    ))
                                                .toList(),
                                            onChanged: (val) {
                                              if (val != null) updatedRole = val;
                                            },
                                            decoration: InputDecoration(labelText: 'Role'),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(doc.id)
                                                .update({'name': updatedName, 'role': updatedRole});
                                            Navigator.pop(context, true); // Return true to indicate save
                                          },
                                          child: Text('Save'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (result == true && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('User updated!'), duration: Duration(seconds: 2)),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete User',
                              onPressed: () async {
                                await firebaseService.deleteUser(doc.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User deleted!')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    // Pending Requests Widget
    Widget pendingRequests = Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pending_actions, color: accentColor, size: 28),
              const SizedBox(width: 10),
              Text('Pending Requests', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor, fontFamily: 'Poppins')),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').where('approved', isEqualTo: false).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!.docs;
                if (users.isEmpty) {
                  return const Center(child: Text('No pending requests.', style: TextStyle(fontFamily: 'Poppins')));
                }
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final doc = users[index];
                    final isTeacher = doc['role'] == 'teacher';
                    final isStudent = doc['role'] == 'student';
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      color: Colors.orange.withOpacity(0.10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isTeacher ? accentColor : (isStudent ? Colors.green : primaryColor),
                          child: Icon(isTeacher ? Icons.person : (isStudent ? Icons.school : Icons.admin_panel_settings), color: Colors.white),
                        ),
                        title: Text(doc['name'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                        subtitle: Text('${doc['email']}\nRole: ${doc['role']}', style: const TextStyle(fontFamily: 'Poppins')),
                        trailing: Switch(
                          value: false,
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                          onChanged: (val) async {
                            if (val) {
                              await firebaseService.approveUser(doc.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User approved!')),
                              );
                            } else {
                              await firebaseService.deleteUser(doc.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User rejected and deleted!')),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Admin Dashboard', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.dashboard),
            tooltip: 'Dashboard',
            onPressed: () {
              setState(() { selectedTab = 0; });
            },
          ),
          IconButton(
            icon: Icon(Icons.people),
            tooltip: 'Users',
            onPressed: () {
              setState(() { selectedTab = 1; });
            },
          ),
          IconButton(
            icon: Icon(Icons.pending_actions),
            tooltip: 'Pending Requests',
            onPressed: () {
              setState(() { selectedTab = 2; });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, color: Color(0xFF008080), size: 36),
                  ),
                  SizedBox(height: 12),
                  Text('Admin', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                  Text('admin@email.com', style: TextStyle(color: Colors.white70, fontFamily: 'Poppins')),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () async {
                Navigator.pop(context);
                // Show dialog to change password
                String? newPassword = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    String password = '';
                    return AlertDialog(
                      title: const Text('Change Password'),
                      content: TextField(
                        obscureText: true,
                        decoration: const InputDecoration(hintText: 'Enter new password'),
                        onChanged: (val) => password = val,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, null),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, password),
                          child: const Text('Change'),
                        ),
                      ],
                    );
                  },
                );
                if (newPassword != null && newPassword.trim().isNotEmpty) {
                  try {
                    // Change password using FirebaseAuth
                    await FirebaseAuth.instance.currentUser?.updatePassword(newPassword.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password changed successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () async {
                Navigator.pop(context);
                // Confirm logout
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (shouldLogout == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          navBar, // Always visible at the top
          Expanded(
            child: Builder(
              builder: (context) {
                if (selectedTab == 0) {
                  return screenWidth > 900
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(flex: 1, child: SingleChildScrollView(child: dashboardActions)),
                          ],
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              dashboardActions,
                            ],
                          ),
                        );
                } else if (selectedTab == 1) {
                  return userManagement;
                } else {
                  return pendingRequests;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Stylish Action Card Widget
class _StylishActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  const _StylishActionCard({required this.icon, required this.title, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: color.withOpacity(0.10),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

// Add this helper widget for nav tabs
class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavTab({required this.icon, required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? Colors.teal : Colors.grey, size: 28),
          Text(label, style: TextStyle(color: selected ? Colors.teal : Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Update summary cards to include icons
class _DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;
  const _DashboardStatCard({required this.icon, required this.title, required this.count, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 6,
      color: color.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 6),
            Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// --- ENHANCED DASHBOARD CARD WIDGET ---
class _EnhancedDashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;
  final bool highlight;
  final VoidCallback onTap;
  const _EnhancedDashboardCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    required this.onTap,
    this.highlight = false,
    Key? key,
  }) : super(key: key);
  @override
  State<_EnhancedDashboardCard> createState() => _EnhancedDashboardCardState();
}
class _EnhancedDashboardCardState extends State<_EnhancedDashboardCard> {
  bool _hovering = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          width: 170,
          height: 130,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _hovering ? widget.color.withOpacity(0.13) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: _hovering ? widget.color.withOpacity(0.35) : Colors.grey.withOpacity(0.18),
                blurRadius: _hovering ? 18 : 8,
                offset: Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: widget.highlight ? Colors.orange : (_hovering ? widget.color : Colors.transparent),
              width: widget.highlight ? 2.5 : (_hovering ? 2 : 1),
            ),
          ),
          transform: _hovering
              ? (() {
                  final m = Matrix4.identity();
                  m.scale(1.04);
                  return m;
                })()
              : Matrix4.identity(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 38, color: widget.color),
              SizedBox(height: 10),
              Text('${widget.count}', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: widget.color)),
              SizedBox(height: 5),
              Text(widget.title, style: TextStyle(fontSize: 17, color: widget.color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
// --- ENHANCED NAV TAB WIDGET ---
class _EnhancedNavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _EnhancedNavTab({required this.icon, required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.teal[100] : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? [BoxShadow(color: Colors.teal.withOpacity(0.18), blurRadius: 8, offset: Offset(0, 3))]
                : [],
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? Colors.teal : Colors.grey, size: 28),
              SizedBox(width: 8),
              Text(label, style: TextStyle(
                color: selected ? Colors.teal[900] : Colors.grey[700],
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 17,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder screens for admin actions
class ManageTeachersScreen extends StatelessWidget {
  const ManageTeachersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF008080);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Manage Teachers', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
      ),
      // Use StreamBuilder to listen to real-time updates from Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'teacher')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // Show loading spinner while data is loading
            return const Center(child: CircularProgressIndicator());
          }
          final teachers = snapshot.data!.docs;
          if (teachers.isEmpty) {
            // Show message if no teachers found
            return const Center(child: Text('No teachers found.', style: TextStyle(fontFamily: 'Poppins')));
          }
          // Show list of teachers
          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final doc = teachers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryColor,
                    child: Text((doc['name'] ?? doc['email'] ?? '?')[0].toUpperCase()),
                  ),
                  title: Text(doc['name'] ?? doc['email'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  subtitle: Text(doc['email'] ?? '', style: const TextStyle(fontFamily: 'Poppins')),
                  trailing: Icon(
                    doc['approved'] == true ? Icons.check_circle : Icons.cancel,
                    color: doc['approved'] == true ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class ManageStudentsScreen extends StatelessWidget {
  const ManageStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF008080);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Manage Students', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
      ),
      // Use StreamBuilder to listen to real-time updates from Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'student')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // Show loading spinner while data is loading
            return const Center(child: CircularProgressIndicator());
          }
          final students = snapshot.data!.docs;
          if (students.isEmpty) {
            // Show message if no students found
            return const Center(child: Text('No students found.', style: TextStyle(fontFamily: 'Poppins')));
          }
          // Show list of students
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final doc = students[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryColor,
                    child: Text((doc['name'] ?? doc['email'] ?? '?')[0].toUpperCase()),
                  ),
                  title: Text(doc['name'] ?? doc['email'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  subtitle: Text(doc['email'] ?? '', style: const TextStyle(fontFamily: 'Poppins')),
                  trailing: Icon(
                    doc['approved'] == true ? Icons.check_circle : Icons.cancel,
                    color: doc['approved'] == true ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class ManageClassesScreen extends StatefulWidget {
  const ManageClassesScreen({super.key});
  @override
  State<ManageClassesScreen> createState() => _ManageClassesScreenState();
}

class _ManageClassesScreenState extends State<ManageClassesScreen> {
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF008080);
    final Color accentColor = const Color(0xFF4FC3F7);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Manage Classes', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'teacher').get(),
        builder: (context, teacherSnap) {
          if (!teacherSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final teachers = teacherSnap.data!.docs;
          if (teachers.isEmpty) {
            return const Center(child: Text('No teachers found.', style: TextStyle(fontFamily: 'Poppins')));
          }
          // Gather all classes from all teachers
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchAllClasses(teachers),
            builder: (context, classSnap) {
              if (!classSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final allClasses = classSnap.data!;
              if (allClasses.isEmpty) {
                return const Center(child: Text('No classes found.', style: TextStyle(fontFamily: 'Poppins')));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: allClasses.length,
                itemBuilder: (context, index) {
                  final classData = allClasses[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: accentColor,
                        child: Icon(Icons.class_, color: primaryColor),
                      ),
                      title: Text(classData['name'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                      subtitle: Text('Teacher: ${classData['teacherName'] ?? ''}\nClass Code: ${classData['classCode'] ?? ''}', style: const TextStyle(fontFamily: 'Poppins')),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Helper to fetch all classes from all teachers
  Future<List<Map<String, dynamic>>> _fetchAllClasses(List<QueryDocumentSnapshot> teachers) async {
    List<Map<String, dynamic>> allClasses = [];
    for (var teacher in teachers) {
      final teacherName = teacher['name'] ?? teacher['email'] ?? '';
      final classesSnap = await teacher.reference.collection('classes').get();
      for (var classDoc in classesSnap.docs) {
        final data = classDoc.data();
        allClasses.add({
          'name': data['name'],
          'classCode': data['classCode'],
          'teacherName': teacherName,
        });
      }
    }
    return allClasses;
  }
}
class ViewAttendanceScreen extends StatefulWidget {
  const ViewAttendanceScreen({super.key});
  @override
  State<ViewAttendanceScreen> createState() => _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends State<ViewAttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF008080);
    final Color accentColor = const Color(0xFF4FC3F7);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('View Attendance', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAllAttendance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = snapshot.data!;
          if (records.isEmpty) {
            return const Center(child: Text('No attendance records found.', style: TextStyle(fontFamily: 'Poppins')));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final rec = records[index];
              final date = rec['date'] is String ? rec['date'] : (rec['date'] as Timestamp?)?.toDate();
              final formattedDate = date is DateTime ? date.toLocal().toString().split(' ')[0] : (date ?? '');
              final present = rec['present'] == true || rec['status'] == 'Present';
              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                color: present ? Colors.green.withOpacity(0.10) : Colors.red.withOpacity(0.10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: present ? Colors.green : Colors.red,
                    child: Icon(present ? Icons.check_circle : Icons.cancel, color: Colors.white),
                  ),
                  title: Text(rec['studentName'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  subtitle: Text('Class: ${rec['className'] ?? ''}\nTeacher: ${rec['teacherName'] ?? ''}\nDate: $formattedDate', style: const TextStyle(fontFamily: 'Poppins')),
                  trailing: Text(present ? 'Present' : 'Absent', style: TextStyle(fontFamily: 'Poppins', color: present ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper to fetch all attendance records from all teachers/classes/students
  Future<List<Map<String, dynamic>>> _fetchAllAttendance() async {
    List<Map<String, dynamic>> allRecords = [];
    final teachersSnap = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'teacher').get();
    for (var teacher in teachersSnap.docs) {
      final teacherName = teacher['name'] ?? teacher['email'] ?? '';
      final classesSnap = await teacher.reference.collection('classes').get();
      for (var classDoc in classesSnap.docs) {
        final className = classDoc['name'] ?? '';
        final studentsSnap = await classDoc.reference.collection('students').get();
        for (var studentDoc in studentsSnap.docs) {
          final studentName = studentDoc['name'] ?? '';
          final attendanceSnap = await studentDoc.reference.collection('attendance').get();
          for (var attDoc in attendanceSnap.docs) {
            final data = attDoc.data();
            allRecords.add({
              'studentName': studentName,
              'className': className,
              'teacherName': teacherName,
              'date': data['date'],
              'present': data['present'],
              'status': data['status'],
            });
          }
        }
      }
    }
    return allRecords;
  }
}

// Pending Users Approval Screen
class PendingUsersScreen extends StatefulWidget {
  const PendingUsersScreen({super.key});
  @override
  State<PendingUsersScreen> createState() => _PendingUsersScreenState();
}

class _PendingUsersScreenState extends State<PendingUsersScreen> {
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF008080);
    final Color accentColor = const Color(0xFF4FC3F7);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Pending Approvals', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('approved', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final pendingUsers = snapshot.data!.docs;
          if (pendingUsers.isEmpty) {
            return const Center(child: Text('No pending users.', style: TextStyle(fontFamily: 'Poppins')));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingUsers.length,
            itemBuilder: (context, index) {
              final doc = pendingUsers[index];
              final isTeacher = doc['role'] == 'teacher';
              return AnimatedContainer(
                duration: Duration(milliseconds: 400 + index * 50),
                curve: Curves.easeInOut,
                child: Card(
                  elevation: 8,
                  margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  color: isTeacher ? accentColor.withOpacity(0.12) : primaryColor.withOpacity(0.10),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: isTeacher ? accentColor : primaryColor,
                          child: Icon(
                            isTeacher ? Icons.person : Icons.school,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(doc['name'] ?? '', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 19)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isTeacher ? accentColor : primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      doc['role'].toString().toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Poppins'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(doc['email'] ?? '', style: const TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Switch(
                              value: false,
                              activeColor: Colors.green,
                              inactiveThumbColor: Colors.red,
                              onChanged: (val) async {
                                if (val) {
                                  await firebaseService.approveUser(doc.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('User approved!')),
                                  );
                                } else {
                                  await firebaseService.deleteUser(doc.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('User rejected and deleted!')),
                                  );
                                }
                              },
                            ),
                            Text('Approve', style: TextStyle(fontFamily: 'Poppins', color: Colors.green, fontWeight: FontWeight.bold)),
                            Text('Reject', style: TextStyle(fontFamily: 'Poppins', color: Colors.red)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
