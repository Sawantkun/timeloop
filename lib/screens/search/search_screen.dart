import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/mock_data.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';
  int _selectedLevel = 0; // 0=All, 1,2,3

  static const _categories = ['All', 'Technology', 'Music', 'Wellness', 'Creative', 'Culinary', 'Languages'];

  List<UserModel> get _filtered {
    return MockUsers.all.where((user) {
      final matchQuery = _query.isEmpty ||
          user.name.toLowerCase().contains(_query.toLowerCase()) ||
          user.skillsOffered.any((s) => s.name.toLowerCase().contains(_query.toLowerCase())) ||
          user.bio.toLowerCase().contains(_query.toLowerCase());

      final matchCat = _selectedCategory == 'All' ||
          user.skillsOffered.any((s) => s.category == _selectedCategory);

      final matchLevel = _selectedLevel == 0 ||
          user.skillsOffered.any((s) => s.level == _selectedLevel);

      return matchQuery && matchCat && matchLevel;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = _filtered;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover Skills',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ).animate().fadeIn().slideY(begin: -0.1),
                  const SizedBox(height: 4),
                  Text(
                    'Find your perfect skill swap partner',
                    style: TextStyle(color: AppColors.lightTextSecondary),
                  ).animate().fadeIn(delay: 80.ms),
                  const SizedBox(height: 16),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 14),
                          child: Icon(Icons.search_rounded, color: AppColors.lightTextSecondary),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _query = v),
                            decoration: InputDecoration(
                              hintText: 'Search skills or people...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              hintStyle: TextStyle(color: AppColors.lightTextSecondary),
                            ),
                          ),
                        ),
                        if (_query.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Category filter
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final selected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: selected ? Colors.white : null,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ).animate(delay: (i * 40).ms).fadeIn().slideX(begin: 0.2);
                },
              ),
            ),

            const SizedBox(height: 8),

            // Level filter row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    '${results.length} ${results.length == 1 ? 'result' : 'results'}',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  ...['All', 'Beginner', 'Mid', 'Expert'].asMap().entries.map((e) {
                    final selected = _selectedLevel == e.key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedLevel = e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.secondary.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.secondary
                                : isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                          ),
                        ),
                        child: Text(
                          e.value,
                          style: TextStyle(
                            color: selected ? AppColors.secondary : null,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Results
            Expanded(
              child: results.isEmpty
                  ? EmptyState(
                      emoji: '🔍',
                      title: 'No results found',
                      subtitle: 'Try a different skill or category',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _UserCard(
                        user: results[i],
                        index: i,
                        onTap: () => context.push('/profile/${results[i].id}', extra: results[i]),
                        onBook: () => context.push('/booking', extra: results[i]),
                        onMessage: () {
                          final chat = context.read<ChatProvider>();
                          final conv = chat.startConversation(results[i]);
                          context.push('/messages/${conv.id}', extra: conv);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onBook;
  final VoidCallback onMessage;

  const _UserCard({
    required this.user,
    required this.index,
    required this.onTap,
    required this.onBook,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(
                  name: user.name,
                  size: 50,
                  showOnline: true,
                  isOnline: user.isOnline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          StarRating(rating: user.rating, size: 13),
                          const SizedBox(width: 6),
                          Text(
                            '(${user.reviewCount})',
                            style: TextStyle(
                              color: AppColors.lightTextSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.lightTextSecondary,
                          ),
                          Text(
                            user.location.split(',').first,
                            style: TextStyle(
                              color: AppColors.lightTextSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${user.completedSwaps} swaps',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              user.bio,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Skills offered
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: user.skillsOffered.map((s) => SkillChip(
                    emoji: s.emoji,
                    label: s.name,
                    color: s.levelColor,
                    selected: true,
                  )).toList(),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onMessage,
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton.icon(
                      onPressed: onBook,
                      icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 16),
                      label: const Text(
                        'Book Swap',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate(delay: (index * 60).ms).fadeIn().slideY(begin: 0.1),
    );
  }
}
