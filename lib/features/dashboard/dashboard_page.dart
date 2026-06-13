import 'package:flutter/material.dart';
import '../employees/presentation/pages/employees_page.dart';
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_outlined),
            tooltip: 'إدارة الموظفين',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmployeesPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('مرحباً بك في WorkPulse'),
      ),
    );
  }
}