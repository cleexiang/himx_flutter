import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/starry_theme.dart';
import '../widgets/glass_container.dart';

class WardrobeHomePage extends StatefulWidget {
  const WardrobeHomePage({super.key});

  @override
  State<WardrobeHomePage> createState() => _WardrobeHomePageState();
}

class _WardrobeHomePageState extends State<WardrobeHomePage> {
  int _selectedBottomTab = 2; // Default to Wardrobe/Center

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background
          _buildBackground(),

          // 2. Character (Center Layer)
          Positioned.fill(child: Center(child: _buildCharacterPlaceholder())),

          // 3. UI Overlay
          SafeArea(
            child: Stack(
              children: [
                // Top Bar
                Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),

                // Left Menu (Clothes types)
                Positioned(
                  left: 16,
                  top: 100,
                  bottom: 120,
                  width: 80,
                  child: _buildLeftMenu(),
                ),

                // Right Menu (Shop items)
                Positioned(
                  right: 16,
                  top: 120,
                  bottom: 120,
                  width: 90,
                  child: _buildRightMenu(),
                ),

                // Bottom Action Buttons (Snap, Glam Boost)
                // Positioned(
                //   bottom: 80,
                //   left: 16,
                //   right: 16,
                //   child: _buildBottomControls(),
                // ),
              ],
            ),
          ),

          // 4. Bottom Navigation Bar (Custom)
          // Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomNavBar()),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: StarryTheme.mainBackgroundGradient,
      ),
      child: Stack(
        children: [
          // Add stars or texture here later
          Positioned(
            top: 50,
            left: 20,
            child: Container(width: 2, height: 2, color: Colors.white),
          ),
          // Placeholder for "Starry" texture
        ],
      ),
    );
  }

  Widget _buildCharacterPlaceholder() {
    // Placeholder for the 3D character
    // Using a clear container area for now, effectively asking the user to imagine or place an image
    // In a real scenario, this would be a 3D model viewer or a high-res image
    return Image.network(
      'https://api.dicebear.com/9.x/avataaars/png?seed=Olivia&backgroundColor=transparent',
      height: 600,
      fit: BoxFit.contain,
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Hearts / Energy
          GlassContainer(
            width: 100,
            height: 40,
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.heart_fill,
                  color: StarryTheme.accentPink,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  '20/90',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // User Profile (Center Top)
          GlassContainer(
            width: 160,
            height: 50,
            borderRadius: BorderRadius.circular(25),
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    'https://api.dicebear.com/9.x/avataaars/png?seed=Felix',
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'olivia_lens',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Currency / Crown
          GlassContainer(
            width: 100,
            height: 40,
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: StarryTheme.accentGold,
                  size: 20,
                ), // Crown placeholder
                SizedBox(width: 8),
                Text(
                  '1.1K',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftMenu() {
    final icons = [
      Icons.face,
      Icons.checkroom, // skirt/dress
      Icons.dry_cleaning, // shirt
      Icons.accessibility_new, // dress
      Icons.shopping_bag, // bag
      Icons.favorite, // necklace
    ];

    final colors = [
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.yellowAccent,
      Colors.redAccent,
      Colors.blueAccent,
    ];

    return GlassContainer(
      width: 70,
      borderRadius: BorderRadius.circular(35),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Gradient for icon background
              gradient: LinearGradient(
                colors: [
                  colors[index].withValues(alpha: 0.8),
                  colors[index].withValues(alpha: 0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icons[index], color: Colors.white, size: 20),
          );
        }),
      ),
    );
  }

  Widget _buildRightMenu() {
    return Column(
      children: [
        const CircleAvatar(
          backgroundColor: Colors.white24,
          radius: 20,
          child: Icon(Icons.keyboard_arrow_up, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildShopItem(Icons.checkroom, 270, true),
              const SizedBox(height: 10),
              _buildShopItem(Icons.checkroom, 360, false),
              const SizedBox(height: 10),
              _buildShopItem(Icons.checkroom, 210, false),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const CircleAvatar(
          backgroundColor: Colors.white24,
          radius: 20,
          child: Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildShopItem(IconData icon, int price, bool isSelected) {
    return GlassContainer(
      height: 110,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(8),
      border: isSelected
          ? Border.all(color: StarryTheme.accentCyan, width: 2)
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Icon(icon, color: Colors.white, size: 40),
          ), // Placeholder for item image
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, size: 12, color: StarryTheme.accentGold),
              Icon(Icons.star, size: 12, color: StarryTheme.accentGold),
              Icon(Icons.star, size: 12, color: StarryTheme.accentGold),
              Icon(Icons.star, size: 12, color: StarryTheme.accentGold),
              Icon(Icons.star, size: 12, color: StarryTheme.accentGold),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: StarryTheme.accentCyan.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond, size: 10, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '$price',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
