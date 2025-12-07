import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/boyfriend.dart';
import '../models/character_settings.dart';
import 'dating_page.dart';

class CharacterSettingsPage extends StatefulWidget {
  final Boyfriend boyfriend;

  const CharacterSettingsPage({
    super.key,
    required this.boyfriend,
  });

  @override
  State<CharacterSettingsPage> createState() => _CharacterSettingsPageState();
}

class _CharacterSettingsPageState extends State<CharacterSettingsPage> {
  final _nicknameController = TextEditingController();
  final _personalityController = TextEditingController();
  final _userNicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    _personalityController.dispose();
    _userNicknameController.dispose();
    super.dispose();
  }

  void _startDating() {
    // Validate inputs
    if (_nicknameController.text.isEmpty ||
        _personalityController.text.isEmpty ||
        _userNicknameController.text.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Missing Information'),
          content: const Text('Please fill in all fields'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    final settings = CharacterSettings(
      boyfriendId: widget.boyfriend.id,
      nickname: _nicknameController.text,
      personality: _personalityController.text,
      userNickname: _userNicknameController.text,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DatingPage(
          boyfriend: widget.boyfriend,
          settings: settings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bronzeColor = Color(0xFFCD7F32);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with blur effect
          Image.network(
            widget.boyfriend.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.person,
                  size: 100,
                  color: Colors.grey,
                ),
              );
            },
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          // Settings card
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Character Settings',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: bronzeColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        _buildTextField(
                          controller: _nicknameController,
                          label: 'Pet Name for Him',
                          hint: 'e.g., Baby, Darling, Honey',
                          icon: Icons.favorite,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _personalityController,
                          label: 'Personality & Preferences',
                          hint: 'e.g., Gentle, Charismatic, Humorous',
                          icon: Icons.emoji_emotions,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _userNicknameController,
                          label: 'His Pet Name for You',
                          hint: 'e.g., Sweetie, Princess, Love',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _startDating,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bronzeColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Start Dating',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: 50,
            left: 20,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back,
                color: bronzeColor,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    const bronzeColor = Color(0xFFCD7F32);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        CupertinoTextField(
          controller: controller,
          maxLines: maxLines,
          placeholder: hint,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          placeholderStyle: TextStyle(
            color: Colors.grey.withValues(alpha: 0.6),
          ),
          style: const TextStyle(
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
