import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/register_screen.dart';
import '../screens/login_screen.dart';
import '../../../core/app_database.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _userExists = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _checkForExistingUser();
  }

  Future<void> _checkForExistingUser() async {
    try {
      final db = await AppDatabase.instance.database;
      final users = await db.query('users', limit: 1);
      setState(() {
        _userExists = users.isNotEmpty;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _userExists = false;
        _isChecking = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo/Hero Image Section
                  _buildHeroSection(size, theme),
                  
                  const SizedBox(height: 32),
                  
                  // Title
                  Text(
                    'Life & Legacy Manager',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    'Uw persoonlijke levenscompas',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Introductie tekst
                  _buildIntroText(theme),
                  
                  const SizedBox(height: 32),
                  
                  // Feature highlights
                  _buildFeatureHighlights(theme),
                  
                  const SizedBox(height: 40),
                  
                  // CTA Buttons
                  if (_isChecking)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildActionButtons(context),
                  
                  const SizedBox(height: 24),
                  
                  // Footer tekst
                  _buildFooterText(theme),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(Size size, ThemeData theme) {
    return Container(
      height: size.height * 0.25,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder voor logo - vervang met je eigen asset
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                size: 40,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'LLM',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroText(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welkom',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'In het leven verzamelen we belangrijke documenten, contracten, en informatie. '
            'Van bankrekeningen tot verzekeringen, van energiecontracten tot persoonlijke wensen. '
            'Maar waar bewaar je dit allemaal? En wat als je nabestaanden deze informatie nodig hebben?',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Life & Legacy Manager is uw persoonlijke levenscompas. '
            'Een veilige, overzichtelijke plek waar u alle belangrijke informatie verzamelt, '
            'beheert en toegankelijk maakt voor uzelf en uw naasten.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights(ThemeData theme) {
    final features = [
      {
        'icon': Icons.security,
        'title': 'Volledig Privé',
        'description': 'Al uw gegevens blijven lokaal op uw apparaat opgeslagen',
      },
      {
        'icon': Icons.dashboard_customize,
        'title': 'Overzichtelijk',
        'description': 'Gestructureerd per thema: geldzaken, huis, juridisch, en meer',
      },
      {
        'icon': Icons.family_restroom,
        'title': 'Voor Nabestaanden',
        'description': 'Alles wat ze moeten weten, op één plek toegankelijk',
      },
      {
        'icon': Icons.attach_file,
        'title': 'Documentbeheer',
        'description': 'Voeg documenten toe of noteer waar ze bewaard zijn',
      },
      {
        'icon': Icons.checklist,
        'title': 'Voortgang Bijhouden',
        'description': 'Zie in één oogopslag welke onderdelen compleet zijn',
      },
      {
        'icon': Icons.lock_clock,
        'title': 'Veilig Bewaard',
        'description': 'Beveiligd met wachtwoord, pincode of biometrie',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wat kunt u verwachten?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ...features.map((feature) => _buildFeatureItem(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              description: feature['description'] as String,
              theme: theme,
            )),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Account aanmaken knop (altijd zichtbaar)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Account Aanmaken',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        // Inloggen knop (alleen als user bestaat)
        if (_userExists) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              child: Text(
                'Inloggen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooterText(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Begin vandaag met het organiseren van uw levensinformatie',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Rust en zekerheid voor u en uw naasten',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}