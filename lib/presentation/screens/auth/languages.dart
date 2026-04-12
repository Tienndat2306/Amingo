import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';
import  '../home/home_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  Language? _selectedLanguage;

  final List<Language> _languages = [
    Language(
      name: 'English',
      nativeName: 'English',
      flagIcon: Icons.flag,
      flagEmoji: '🇺🇸',
      countryCode: 'US',
    ),
    Language(
      name: 'Spanish',
      nativeName: 'Español',
      flagIcon: Icons.flag,
      flagEmoji: '🇪🇸',
      countryCode: 'ES',
    ),
    Language(
      name: 'French',
      nativeName: 'Français',
      flagIcon: Icons.flag,
      flagEmoji: '🇫🇷',
      countryCode: 'FR',
    ),
    Language(
      name: 'German',
      nativeName: 'Deutsch',
      flagIcon: Icons.flag,
      flagEmoji: '🇩🇪',
      countryCode: 'DE',
    ),
    Language(
      name: 'Japanese',
      nativeName: '日本語',
      flagIcon: Icons.flag,
      flagEmoji: '🇯🇵',
      countryCode: 'JP',
    ),
    Language(
      name: 'Korean',
      nativeName: '한국어',
      flagIcon: Icons.flag,
      flagEmoji: '🇰🇷',
      countryCode: 'KR',
    ),
  ];

  void _handleContinue() {
    if (_selectedLanguage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected language: ${_selectedLanguage!.name}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a language to continue'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFB02500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E3),
      body: Column(
        children: [
          // TopAppBar
          _buildTopAppBar(colorScheme),
          // Main Content
          Expanded(
            child: Stack(
              children: [
                // Main scrollable content
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      // Hero Header
                      _buildHeroHeader(colorScheme),
                      const SizedBox(height: 40),
                      // Language Selection Grid
                      _buildLanguageGrid(),
                      const SizedBox(height: 120), // Space for floating button
                    ],
                  ),
                ),
                // Floating Footer Action
                _buildFloatingFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(ColorScheme colorScheme) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF6E3),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back,
                color: const Color(0xFF775600),
                size: 24,
              ),
            ),
          ),
          const Spacer(),
          // Spacer for centering (placeholder for back button symmetry)
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(ColorScheme colorScheme) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(48),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.tertiary.withValues(alpha: 0.2),
                    blurRadius: 32,
                  ),
                ],
              ),
            ),
            Image.asset(
              'assets/logo/amingo_logo_5-removebg-preview.png',
              height: 180,
              width: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flutter_dash,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Title
        Text(
          'What language do you want to learn?',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: const Color(0xFF3A2D00),
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle
        Text(
          'Choose the first step for your journey',
          textAlign: TextAlign.center,
          style: GoogleFonts.beVietnamPro(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B5A23),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        childAspectRatio: 6,
      ),
      itemCount: _languages.length,
      itemBuilder: (context, index) {
        final language = _languages[index];
        final isSelected = _selectedLanguage == language;

        return _LanguageButton(
          language: language,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedLanguage = language;
            });
          },
        );
      },
    );
  }

  Widget _buildFloatingFooter() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6E3).withValues(alpha: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF775600),
                      foregroundColor: const Color(0xFFFFF1DC),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFF3A2D00).withValues(alpha: 0.15),
                    ),
                    child: Text(
                      'Continue',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final Language language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : const Color(0xFFFFF0C9),
          borderRadius: BorderRadius.circular(100),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFFFDBC13).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            // Flag container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: _buildFlagIcon(),
              ),
            ),
            const SizedBox(width: 16),
            // Language name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFFFFF1DC)
                          : const Color(0xFF3A2D00),
                    ),
                  ),
                  if (language.nativeName != language.name)
                    Text(
                      language.nativeName,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFFFFF1DC).withValues(alpha: 0.8)
                            : const Color(0xFF6B5A23),
                      ),
                    ),
                ],
              ),
            ),
            // Check icon if selected
            if (isSelected)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1DC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF775600),
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagIcon() {
    // Sử dụng country code để tạo flag icon phù hợp
    switch (language.countryCode) {
      case 'US':
        return const Text('🇺🇸', style: TextStyle(fontSize: 28));
      case 'ES':
        return const Text('🇪🇸', style: TextStyle(fontSize: 28));
      case 'FR':
        return const Text('🇫🇷', style: TextStyle(fontSize: 28));
      case 'DE':
        return const Text('🇩🇪', style: TextStyle(fontSize: 28));
      case 'JP':
        return const Text('🇯🇵', style: TextStyle(fontSize: 28));
      case 'KR':
        return const Text('🇰🇷', style: TextStyle(fontSize: 28));
      case 'CN':
        return const Text('🇨🇳', style: TextStyle(fontSize: 28));
      case 'IT':
        return const Text('🇮🇹', style: TextStyle(fontSize: 28));
      case 'PT':
        return const Text('🇵🇹', style: TextStyle(fontSize: 28));
      case 'RU':
        return const Text('🇷🇺', style: TextStyle(fontSize: 28));
      case 'SA':
        return const Text('🇸🇦', style: TextStyle(fontSize: 28));
      case 'IN':
        return const Text('🇮🇳', style: TextStyle(fontSize: 28));
      default:
        return Icon(
          Icons.flag,
          color: const Color(0xFF775600),
          size: 28,
        );
    }
  }
}

class Language {
  final String name;
  final String nativeName;
  final IconData flagIcon;
  final String flagEmoji;
  final String countryCode;

  Language({
    required this.name,
    required this.nativeName,
    required this.flagIcon,
    required this.flagEmoji,
    required this.countryCode,
  });
}