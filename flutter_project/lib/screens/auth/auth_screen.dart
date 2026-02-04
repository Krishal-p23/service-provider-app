import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import 'login_tab.dart';
import 'register_tab.dart';
import 'worker_login_tab.dart';
import 'worker_register_tab.dart';

class AuthScreen extends StatefulWidget {
  final UserRole initialRole;

  const AuthScreen({
    super.key,
    this.initialRole = UserRole.customer,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late UserRole _selectedRole;
  bool _isLoginMode = true;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  Color _getRoleColor() {
    return _selectedRole == UserRole.customer
        ? const Color(0xFF00897B) // Teal for customer
        : const Color(0xFF1976D2); // Blue for worker
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final roleColor = _getRoleColor();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with role toggle
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Role Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C2C2C)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildRoleButton(
                            UserRole.customer,
                            isDark,
                            roleColor,
                          ),
                        ),
                        Expanded(
                          child: _buildRoleButton(
                            UserRole.worker,
                            isDark,
                            roleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content area - switches between login and register based on role
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: _buildContent(roleColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build content based on selected role and mode
  Widget _buildContent(Color roleColor) {
    if (_selectedRole == UserRole.customer) {
      // Customer Login/Register
      return _isLoginMode
          ? LoginTab(
              key: const ValueKey('customer_login'),
              roleColor: roleColor,
              onSwitchToRegister: () {
                setState(() {
                  _isLoginMode = false;
                });
              },
            )
          : RegisterTab(
              key: const ValueKey('customer_register'),
              roleColor: roleColor,
              onSwitchToLogin: () {
                setState(() {
                  _isLoginMode = true;
                });
              },
            );
    } else {
      // Worker Login/Register
      return _isLoginMode
          ? WorkerLoginTab(
              key: const ValueKey('worker_login'),
              roleColor: roleColor,
              onSwitchToRegister: () {
                setState(() {
                  _isLoginMode = false;
                });
              },
            )
          : WorkerRegisterTab(
              key: const ValueKey('worker_register'),
              roleColor: roleColor,
              onSwitchToLogin: () {
                setState(() {
                  _isLoginMode = true;
                });
              },
            );
    }
  }

  Widget _buildRoleButton(UserRole role, bool isDark, Color roleColor) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? roleColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          role.displayName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}