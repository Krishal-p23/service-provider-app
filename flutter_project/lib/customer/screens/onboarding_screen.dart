import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import '../models/user_role.dart';
// import '../providers/theme_provider.dart';
import '../../auth/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _cardController;
  late AnimationController _slideController;
  late AnimationController _labelController;
  late AnimationController _rolesController;
  late AnimationController _buttonController;

  late Animation<double> _logoOpacity;
  late Animation<double> _cardOpacity;
  late Animation<Alignment> _slideAnimation;
  late Animation<double> _labelOpacity;
  late Animation<double> _rolesOpacity;
  late Animation<double> _buttonOpacity;

  UserRole _selectedRole = UserRole.customer;
  
  bool _showLogo = false;
  bool _showCard = false;
  bool _slideUp = false;
  bool _showLabel = false;
  bool _showRoles = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();

    // Logo fade in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    // Card fade in
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardOpacity = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeIn,
    );

    // Slide animation (center to top)
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Alignment>(
      begin: Alignment.center,
      end: Alignment.topCenter,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    // Label fade in
    _labelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _labelOpacity = CurvedAnimation(
      parent: _labelController,
      curve: Curves.easeIn,
    );

    // Role cards fade in
    _rolesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rolesOpacity = CurvedAnimation(
      parent: _rolesController,
      curve: Curves.easeIn,
    );

    // Button fade in
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buttonOpacity = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeIn,
    );

    _startAnimations();
  }

  void _startAnimations() async {
    // Step 1: Show logo at center
    setState(() => _showLogo = true);
    await _logoController.forward();

    // Step 2: Show card below logo (200ms delay)
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _showCard = true);
    await _cardController.forward();

    // Step 3: Wait 3 seconds, then slide up
    await Future.delayed(const Duration(milliseconds: 3000));
    setState(() => _slideUp = true);
    await _slideController.forward();

    // Step 4: Show "Login with your role" label
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _showLabel = true);
    await _labelController.forward();

    // Step 5: Show role cards
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _showRoles = true);
    await _rolesController.forward();

    // Step 6: Show button
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _showButton = true);
    await _buttonController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _cardController.dispose();
    _slideController.dispose();
    _labelController.dispose();
    _rolesController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            // Logo + Card (slides from center to top)
            AlignTransition(
              alignment: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.only(top: _slideUp ? 40 : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    if (_showLogo)
                      FadeTransition(
                        opacity: _logoOpacity,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00897B), Color(0xFF00695C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00897B).withOpacity(0.3),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.home_repair_service_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Info Card with fixed height container to prevent logo shift
                    SizedBox(
                      height: 70, // Fixed height to reserve space
                      child: _showCard
                          ? FadeTransition(
                              opacity: _cardOpacity,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 48),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E1E1E)
                                      : const Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Trusted Home Services\nNear You',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    height: 1.0,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(), // Empty space when not shown
                    ),
                  ],
                ),
              ),
            ),

            // "Login with your role" Label (appears after slide, separate from card)
            if (_showLabel)
              Positioned(
                top: 240,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _labelOpacity,
                  child: Center(
                    child: Text(
                      'Login with your role',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: (isDark ? Colors.grey.shade400 : Colors.grey.shade700)
                            .withOpacity(0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

            // Role Cards (appear below label)
            if (_showRoles)
              Positioned(
                top: 280,
                left: 24,
                right: 24,
                child: FadeTransition(
                  opacity: _rolesOpacity,
                  child: Column(
                    children: [
                      // Customer Role Card
                      _buildRoleCard(
                        role: UserRole.customer,
                        icon: Icons.person_rounded,
                        theme: theme,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 16),

                      // Worker Role Card
                      _buildRoleCard(
                        role: UserRole.worker,
                        icon: Icons.work_rounded,
                        theme: theme,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),

            // Get Started Button (fixed at bottom)
            if (_showButton)
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: FadeTransition(
                  opacity: _buttonOpacity,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AuthScreen(initialRole: _selectedRole),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: const Color(0xFF00897B).withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
// this method builds a role selection card and highlights it when selected 
  Widget _buildRoleCard({
    required UserRole role,
    required IconData icon,
    required ThemeData theme,
    required bool isDark,
  }) {
    final isSelected = _selectedRole == role;
    final roleColor = role == UserRole.customer  
        ? const Color(0xFF00897B)
        : const Color(0xFF1976D2);

    return GestureDetector( // handle tap to select role
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? roleColor.withOpacity(0.12)
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? roleColor
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: roleColor.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Circular Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected ? roleColor : roleColor.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: roleColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.white : roleColor,
              ),
            ),
            const SizedBox(width: 16),
            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? roleColor : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // Selection Indicator
            AnimatedOpacity( // fade in/out check icon
              duration: const Duration(milliseconds: 250),
              opacity: isSelected ? 1.0 : 0.0,
              child: Icon(
                Icons.check_circle_rounded,
                color: roleColor,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
