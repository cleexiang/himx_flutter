import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../models/himx_role.dart';
import '../theme/app_theme.dart';
import '../services/diary_service.dart';
import 'package:intl/intl.dart';

class DiaryPage extends StatefulWidget {
  final HimxRole role;

  const DiaryPage({super.key, required this.role});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> with SingleTickerProviderStateMixin {
  final DiaryService _diaryService = DiaryService();

  // Data state
  List<DiaryEntry> _diaryEntries = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDiaryData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadDiaryData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load diary entries from API
      final entries = await _diaryService.getDiaryList(
        roleId: widget.role.roleId,
        pageSize: 50,
        pageNumber: 1,
      );

      setState(() {
        _diaryEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildTimelineTab()),
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
              'Love Diary',
              style: TextStyle(color: AppTheme.titleText, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: _createNewEntry,
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.shadowOverlay, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.shadowOverlay),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.bodyText),
            const SizedBox(height: 16),
            Text(
              'Failed to load diary',
              style: const TextStyle(color: AppTheme.bodyText, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppTheme.bodyText, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDiaryData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.selectedBackground,
                foregroundColor: AppTheme.titleText,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_diaryEntries.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadDiaryData,
      color: AppTheme.shadowOverlay,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: _diaryEntries.length,
        itemBuilder: (context, index) {
          final isLast = index == _diaryEntries.length - 1;
          return _buildTimelineItem(_diaryEntries[index], isLast);
        },
      ),
    );
  }

  Widget _buildTimelineItem(DiaryEntry entry, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Date and timeline
          SizedBox(
            width: 60,
            child: Column(
              children: [
                // Date
                Text(
                  DateFormat('MM/dd').format(entry.timestamp),
                  style: const TextStyle(
                    color: AppTheme.bodyText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // Circle marker
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.shadowOverlay,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.pageBackground, width: 2),
                  ),
                ),
                // Vertical line (if not last)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 4),
                      color: AppTheme.unselectedBackground,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right side: Content card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: AppTheme.unselectedBoxDecoration(borderRadius: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _viewEntryDetail(entry),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with icon
                        Row(
                          children: [
                            Text(entry.type.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.title,
                                style: const TextStyle(
                                  color: AppTheme.titleText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Content
                        Text(
                          entry.content,
                          style: const TextStyle(
                            color: AppTheme.bodyText,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Photos in grid
                        if (entry.mediaUrls.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildPhotoGrid(entry.mediaUrls),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List<String> mediaUrls) {
    final count = mediaUrls.length;
    if (count == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          mediaUrls[0],
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    // Grid layout for 2+ photos using Wrap instead of GridView
    final displayCount = count > 4 ? 4 : count;
    final rows = (displayCount / 2).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * 2;
        final endIndex = (startIndex + 2 > displayCount) ? displayCount : startIndex + 2;
        final itemsInRow = endIndex - startIndex;

        return Padding(
          padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? 8 : 0),
          child: Row(
            children: List.generate(itemsInRow, (colIndex) {
              final index = startIndex + colIndex;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: colIndex == 0 && itemsInRow == 2 ? 8 : 0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            mediaUrls[index],
                            fit: BoxFit.cover,
                          ),
                          if (index == 3 && count > 4)
                            Container(
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: Text(
                                  '+${count - 4}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: AppTheme.unselectedBackground, shape: BoxShape.circle),
            child: const Icon(Icons.auto_stories, size: 80, color: AppTheme.shadowOverlay),
          ),
          const SizedBox(height: 30),
          const Text(
            'No Memories Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.titleText),
          ),
          const SizedBox(height: 12),
          const Text(
            'Start creating beautiful moments together',
            style: TextStyle(fontSize: 16, color: AppTheme.bodyText),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _createNewEntry,
            icon: const Icon(Icons.add),
            label: const Text('Create First Memory'),
            style: AppTheme.primaryButtonStyle(),
          ),
        ],
      ),
    );
  }

  void _createNewEntry() {
    // TODO: Implement create new diary entry
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Create diary entry feature coming soon!')));
  }

  void _viewEntryDetail(DiaryEntry entry) {
    // TODO: Implement view diary entry detail
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('View: ${entry.title}')));
  }
}
