import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/himx_role.dart';
import 'dating_page.dart';
import '../theme/app_theme.dart';
import '../services/himx_api.dart';

class CharacterSettingsPage extends StatefulWidget {
  final HimxRole role;

  const CharacterSettingsPage({super.key, required this.role});

  @override
  State<CharacterSettingsPage> createState() => _CharacterSettingsPageState();
}

class _CharacterSettingsPageState extends State<CharacterSettingsPage> {
  final _nicknameController = TextEditingController();
  final _personalityController = TextEditingController();
  final _userNicknameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _personalityController.dispose();
    _userNicknameController.dispose();
    super.dispose();
  }

  Future<void> _startDating() async {
    // Validate inputs
    if (_nicknameController.text.isEmpty ||
        _personalityController.text.isEmpty ||
        _userNicknameController.text.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Missing Information'),
          content: const Text('Please fill in all fields'),
          actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
        ),
      );
      return;
    }

    final nickname = _nicknameController.text;
    final personality = _personalityController.text;
    final userNickname = _userNicknameController.text;

    setState(() => _isSubmitting = true);
    try {
      await HimxApi().startDating(
        roleId: widget.role.roleId,
        nickname: nickname,
        personality: personality,
        userNickname: userNickname,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DatingPage(
            role: widget.role,
            nickname: nickname,
            personality: personality,
            userNickname: userNickname,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Start Dating Failed'),
          content: Text('$e'),
          actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background color
          Container(color: AppTheme.pageBackground),
          // Settings card
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: AppTheme.unselectedBoxDecoration(borderRadius: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Character Settings', style: AppTheme.titleTextStyle, textAlign: TextAlign.center),
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
                          onPressed: _isSubmitting ? null : _startDating,
                          style: AppTheme.primaryButtonStyle(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.buttonText),
                                )
                              : const Text('Start Dating', style: AppTheme.buttonTextStyle),
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
              child: const Icon(Icons.arrow_back, color: AppTheme.shadowOverlay, size: 32),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.titleText),
          ),
        ),
        CupertinoTextField(
          controller: controller,
          maxLines: maxLines,
          placeholder: hint,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.pageBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.shadowOverlay.withValues(alpha: 0.3), width: 1),
          ),
          placeholderStyle: TextStyle(color: AppTheme.bodyText.withValues(alpha: 0.5)),
          style: const TextStyle(color: AppTheme.bodyText),
        ),
      ],
    );
  }
}
