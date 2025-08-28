import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/anime_info.dart';
import '../models/anime_character.dart';
import '../providers/anime_api_providers.dart';
import '../../../core/constants/app_constants.dart';
import 'character_detail_screen.dart';

class AnimeSearchScreen extends ConsumerStatefulWidget {
  const AnimeSearchScreen({super.key});

  @override
  ConsumerState<AnimeSearchScreen> createState() => _AnimeSearchScreenState();
}

class _AnimeSearchScreenState extends ConsumerState<AnimeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = '';
  bool _showCharacters = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime & Characters'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(children: [_buildSearchBar(), _buildToggleButtons()]),
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildPopularContent()
          : _showCharacters
          ? _buildCharacterResults()
          : _buildAnimeResults(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        decoration: InputDecoration(
          hintText: _showCharacters
              ? 'Search characters...'
              : 'Search anime...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim();
          });
        },
        onSubmitted: (value) {
          setState(() {
            _searchQuery = value.trim();
          });
        },
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Anime'),
                  icon: Icon(Icons.movie),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Characters'),
                  icon: Icon(Icons.person),
                ),
              ],
              selected: {_showCharacters},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _showCharacters = selection.first;
                  if (_searchQuery.isNotEmpty) {
                    // Trigger search refresh when switching modes
                    _searchQuery = _searchController.text.trim();
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularContent() {
    return _showCharacters ? _buildPopularCharacters() : _buildPopularAnime();
  }

  Widget _buildPopularAnime() {
    final topAnimeAsync = ref.watch(topAnimeProvider);

    return topAnimeAsync.when(
      data: (animeList) => _buildAnimeList(animeList, 'Popular Anime'),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          _buildErrorWidget('Failed to load popular anime'),
    );
  }

  Widget _buildPopularCharacters() {
    // For now, we'll show a placeholder since we don't have a direct popular characters endpoint
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64),
          SizedBox(height: 16),
          Text('Search for characters to get started!'),
        ],
      ),
    );
  }

  Widget _buildAnimeResults() {
    final searchResultsAsync = ref.watch(searchAnimeProvider(_searchQuery));

    return searchResultsAsync.when(
      data: (animeList) => animeList.isEmpty
          ? _buildNoResults('No anime found')
          : _buildAnimeList(animeList, 'Search Results'),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget('Search failed'),
    );
  }

  Widget _buildCharacterResults() {
    final searchResultsAsync = ref.watch(
      searchCharactersProvider(_searchQuery),
    );

    return searchResultsAsync.when(
      data: (characterList) => characterList.isEmpty
          ? _buildNoResults('No characters found')
          : _buildCharacterList(characterList, 'Search Results'),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget('Search failed'),
    );
  }

  Widget _buildAnimeList(List<AnimeInfo> animeList, String title) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final anime = animeList[index];
              return _buildAnimeCard(anime, index);
            }, childCount: animeList.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildCharacterList(List<AnimeCharacter> characterList, String title) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final character = characterList[index];
              return _buildCharacterCard(character, index);
            }, childCount: characterList.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildAnimeCard(AnimeInfo anime, int index) {
    return GestureDetector(
          onTap: () {
            // Navigate to anime detail screen
            // You can create an AnimeDetailScreen similar to CharacterDetailScreen
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: CachedNetworkImage(
                    imageUrl: anime.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: const Icon(Icons.movie, size: 32),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          anime.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (anime.score > 0)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                anime.score.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        const Spacer(),
                        Text(
                          anime.type,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: (index * 100).ms)
        .fadeIn(duration: AppConstants.mediumAnimation);
  }

  Widget _buildCharacterCard(AnimeCharacter character, int index) {
    return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CharacterDetailScreen(
                  characterId: character.id,
                  character: character,
                ),
              ),
            );
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: character.imageUrl,
                      width: 60,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 60,
                        height: 80,
                        color: Theme.of(context).colorScheme.surface,
                        child: const Icon(Icons.person, size: 24),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 60,
                        height: 80,
                        color: Theme.of(context).colorScheme.surface,
                        child: const Icon(Icons.person, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          character.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (character.japaneseName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            character.japaneseName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          character.animeName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (character.role.isNotEmpty &&
                            character.role != 'Unknown') ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              character.role,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (index * 100).ms)
        .fadeIn(duration: AppConstants.mediumAnimation);
  }

  Widget _buildNoResults(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Refresh the current view
              setState(() {});
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
