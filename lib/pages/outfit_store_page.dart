import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../models/himx_role.dart';
import '../theme/app_theme.dart';

class OutfitStorePage extends StatefulWidget {
  final HimxRole role;

  const OutfitStorePage({super.key, required this.role});

  @override
  State<OutfitStorePage> createState() => _OutfitStorePageState();
}

class _OutfitStorePageState extends State<OutfitStorePage> {
  OutfitCategory? _selectedCategory;
  final List<Outfit> _outfits = Outfits.getPresetOutfits();
  CharacterOutfit? _characterOutfit;

  // Mock user coins
  int _userCoins = 500;

  @override
  void initState() {
    super.initState();
    _loadCharacterOutfit();
  }

  Future<void> _loadCharacterOutfit() async {
    // TODO: Replace with actual API call
    setState(() {
      _characterOutfit = CharacterOutfit(
        roleId: widget.role.roleId,
        currentOutfitId: 'casual_01',
        ownedOutfitIds: ['casual_01', 'casual_02'],
      );
    });
  }

  List<Outfit> get _filteredOutfits {
    if (_selectedCategory == null) {
      return _outfits;
    }
    return _outfits.where((outfit) => outfit.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryFilter(),
            Expanded(child: _buildOutfitGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppTheme.titleText),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Wardrobe',
              style: TextStyle(color: AppTheme.titleText, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // Coin balance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.selectedBackground.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: AppTheme.shadowOverlay, size: 20),
                const SizedBox(width: 6),
                Text(
                  '$_userCoins',
                  style: const TextStyle(color: AppTheme.titleText, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildCategoryChip(null, 'All', Icons.grid_view),
          ...OutfitCategory.values.map((category) {
            return _buildCategoryChip(category, category.displayName, _getCategoryIcon(category));
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(OutfitCategory? category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.selectedBackground : AppTheme.unselectedBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.selectedBackground : Colors.transparent, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? AppTheme.buttonText : AppTheme.bodyText),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.buttonText : AppTheme.bodyText,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(OutfitCategory category) {
    switch (category) {
      case OutfitCategory.casual:
        return Icons.checkroom;
      case OutfitCategory.formal:
        return Icons.business_center;
      case OutfitCategory.traditional:
        return Icons.temple_buddhist;
      case OutfitCategory.sportswear:
        return Icons.sports_basketball;
      case OutfitCategory.pajamas:
        return Icons.nightlight;
      case OutfitCategory.costume:
        return Icons.theater_comedy;
      case OutfitCategory.seasonal:
        return Icons.wb_sunny;
      case OutfitCategory.wedding:
        return Icons.favorite;
      case OutfitCategory.fantasy:
        return Icons.auto_awesome;
    }
  }

  Widget _buildOutfitGrid() {
    if (_filteredOutfits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checkroom_outlined, size: 80, color: AppTheme.shadowOverlay.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('No outfits in this category', style: TextStyle(color: AppTheme.bodyText, fontSize: 16)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredOutfits.length,
      itemBuilder: (context, index) {
        return _buildOutfitCard(_filteredOutfits[index]);
      },
    );
  }

  Widget _buildOutfitCard(Outfit outfit) {
    final isOwned = _characterOutfit?.ownedOutfitIds.contains(outfit.id) ?? false;
    final isEquipped = _characterOutfit?.currentOutfitId == outfit.id;
    final canAfford = _userCoins >= outfit.price;

    return GestureDetector(
      onTap: () => _handleOutfitTap(outfit, isOwned, isEquipped),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEquipped ? AppTheme.shadowOverlay : _getRarityColor(outfit.rarity).withValues(alpha: 0.5),
            width: isEquipped ? 3 : 2,
          ),
          color: AppTheme.unselectedBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      color: Colors.grey.shade800,
                      image: DecorationImage(image: NetworkImage(outfit.thumbnailUrl), fit: BoxFit.cover),
                    ),
                  ),
                  // Rarity badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRarityColor(outfit.rarity),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        outfit.rarity.displayName,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Limited badge
                  if (outfit.isLimited)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(8)),
                        child: const Text(
                          'LIMITED',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  // Equipped badge
                  if (isEquipped)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppTheme.shadowOverlay, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 16),
                      ),
                    ),
                  // Lock overlay for locked items
                  if (!isOwned)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: const Center(child: Icon(Icons.lock, color: Colors.white, size: 32)),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outfit.name,
                    style: const TextStyle(color: AppTheme.titleText, fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (!isOwned)
                    Row(
                      children: [
                        Icon(Icons.monetization_on, size: 14, color: canAfford ? AppTheme.shadowOverlay : Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          '${outfit.price}',
                          style: TextStyle(
                            color: canAfford ? AppTheme.shadowOverlay : Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      isEquipped ? 'Equipped' : 'Owned',
                      style: TextStyle(
                        color: isEquipped ? AppTheme.shadowOverlay : AppTheme.bodyText,
                        fontSize: 12,
                        fontWeight: isEquipped ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(OutfitRarity rarity) {
    return Color(int.parse(rarity.color.substring(1), radix: 16) + 0xFF000000);
  }

  void _handleOutfitTap(Outfit outfit, bool isOwned, bool isEquipped) {
    if (isEquipped) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This outfit is already equipped')));
      return;
    }

    if (isOwned) {
      _equipOutfit(outfit);
    } else {
      _showPurchaseDialog(outfit);
    }
  }

  void _equipOutfit(Outfit outfit) {
    setState(() {
      _characterOutfit = _characterOutfit?.copyWith(currentOutfitId: outfit.id, lastChanged: DateTime.now());
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Equipped: ${outfit.name}')));

    // TODO: Call API to update character outfit
  }

  void _showPurchaseDialog(Outfit outfit) {
    final canAfford = _userCoins >= outfit.price;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.unselectedBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(outfit.name, style: const TextStyle(color: AppTheme.titleText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(outfit.description, style: const TextStyle(color: AppTheme.bodyText)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Price:', style: TextStyle(color: AppTheme.bodyText, fontSize: 15)),
                Row(
                  children: [
                    Icon(Icons.monetization_on, color: canAfford ? AppTheme.shadowOverlay : Colors.red, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${outfit.price}',
                      style: TextStyle(
                        color: canAfford ? AppTheme.shadowOverlay : Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (!canAfford) ...[
              const SizedBox(height: 8),
              Text(
                'Not enough coins. You need ${outfit.price - _userCoins} more.',
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.bodyText)),
          ),
          if (canAfford)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _purchaseOutfit(outfit);
              },
              style: AppTheme.primaryButtonStyle(),
              child: const Text('Purchase', style: AppTheme.buttonTextStyle),
            ),
        ],
      ),
    );
  }

  void _purchaseOutfit(Outfit outfit) {
    setState(() {
      _userCoins -= outfit.price;
      _characterOutfit = _characterOutfit?.copyWith(
        ownedOutfitIds: [...(_characterOutfit?.ownedOutfitIds ?? []), outfit.id],
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Purchased: ${outfit.name}! 🎉')));

    // TODO: Call API to purchase outfit
  }
}
