import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/employees_provider.dart';
import 'package:go_router/go_router.dart';
class EmployeesPage extends ConsumerStatefulWidget {
  const EmployeesPage({super.key});

  @override
  ConsumerState<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends ConsumerState<EmployeesPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(employeesProvider.notifier).loadEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الموظفين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push('/activation-codes/generate');
            },
          ),
          IconButton(
            onPressed: () {
              ref.read(employeesProvider.notifier).loadEmployees();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state.employees.isEmpty) {
            return const Center(
              child: Text('لا يوجد موظفين حالياً'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.employees.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final employee = state.employees[index];

              return Card(
                elevation: 3,
                child: ListTile(
                  title: Text(employee.fullName),
                  subtitle: Text(
                    '${employee.email}\nالدور: ${employee.role ?? 'employee'}',
                  ),
                  isThreeLine: true,
                  trailing: Switch(
                    value: employee.isActive ?? false,
                    onChanged: (value) {
                      if (value) {
                        ref
                            .read(employeesProvider.notifier)
                            .activateEmployee(employee.id);
                      } else {
                        ref
                            .read(employeesProvider.notifier)
                            .deactivateEmployee(employee.id);
                      }
                    },
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