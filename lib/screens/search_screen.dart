import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import '../models/search_result.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/user_result_card.dart';
import '../widgets/category_chip.dart';
import '../providers/search_providers.dart';
import '../providers/theme_provider.dart';
import 'about_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);

    final currentState = searchAsync.maybeWhen(
      data: (s) => s,
      orElse: () => const SearchState(),
    );
    if (_searchController.text != currentState.query) {
      _searchController.text = currentState.query;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              title: const Text('Discover Pros'),
              surfaceTintColor: Colors.transparent,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(72),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: SearchBarWidget(
                    controller: _searchController,
                    onChanged: notifier.onQueryChanged,
                    onClear: notifier.clear,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: searchAsync.when(
                  loading: () => _buildShimmerList(context),
                  error: (err, _) => _buildError(err, notifier),
                  data: (state) => _buildResults(state, notifier),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildResults(SearchState state, SearchNotifier notifier) {
    if (state.query.trim().isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: Lottie.asset(
                'assets/animations/search_prompt.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            _PulseIcon(
              icon: Icons.search,
              color: Theme.of(context).colorScheme.primary,
              size: 56,
            ),
            const SizedBox(height: 12),
            Text(
              'Start typing to search',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ],
        ),
      );
    }

    if (state.allResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          children: [
            SizedBox(
              height: 160,
              child: Lottie.asset(
                'assets/animations/no_results.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            _PulseIcon(
              icon: Icons.search_off,
              color: Theme.of(context).colorScheme.primary,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.categories.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Matching Categories (${state.categories.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                children: state.categories.map(
                  (category) => CategoryChip(
                    category: category,
                    onTap: () => notifier.onCategorySelected(category),
                  ),
                ).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (state.usernameResults.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Matching Usernames (${state.usernameResults.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...state.usernameResults.map(
              (result) => UserResultCard(
                result: result,
                onTap: () {},
              ),
            ),
          ],

          if (state.usernameResults.length < state.allResults.length) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Other Results (${state.allResults.length - state.usernameResults.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...() {
              final usernameUserIds = state.usernameResults
                  .map((result) => result.user.id)
                  .toSet();
              return state.allResults
                  .where((r) => !usernameUserIds.contains(r.user.id))
                  .map(
                    (result) => UserResultCard(result: result, onTap: () {}),
                  );
            }(),
          ],
        ],
      ),
    );
  }

  Widget _buildError(Object error, SearchNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
            const SizedBox(height: 8),
            Text(
              'Something went wrong',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: notifier.retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[300]!;
    final highlight = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[100]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: List.generate(6, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Shimmer.fromColors(
              baseColor: base,
              highlightColor: highlight,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: base,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14, width: double.infinity, color: base),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 160, color: base),
                        const SizedBox(height: 8),
                        Container(height: 12, width: double.infinity, color: base),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 1) {
          Navigator.of(context).pushReplacementNamed('/about');
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          label: 'About',
        ),
      ],
    );
  }

}

class _PulseIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  const _PulseIcon({required this.icon, required this.color, required this.size});

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.96, end: 1.06).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _opacity = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Icon(widget.icon, color: widget.color, size: widget.size),
      ),
    );
  }
}

