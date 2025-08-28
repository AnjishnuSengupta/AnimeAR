import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/anime_character.dart';
import '../providers/anime_api_providers.dart';
import '../../../core/constants/app_constants.dart';

class CharacterDetailScreen extends ConsumerWidget {
  final String characterId;
  final AnimeCharacter? character;

  const CharacterDetailScreen({
    super.key,
    required this.characterId,
    this.character,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterAsync = character != null
        ? AsyncValue.data(character)
        : ref.watch(characterDetailsProvider(characterId));

    return Scaffold(
      body: characterAsync.when(
        data: (characterData) => characterData != null
            ? _buildCharacterDetail(context, ref, characterData)
            : _buildNotFound(context),
        loading: () => _buildLoading(context),
        error: (error, stack) => _buildError(context, error),
      ),
    );
  }

  Widget _buildCharacterDetail(
    BuildContext context,
    WidgetRef ref,
    AnimeCharacter character,
  ) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, character),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildCharacterHeader(context, character),
              _buildCharacterInfo(context, character),
              _buildAnimeInfo(context, ref, character),
              _buildAbilitiesSection(context, character),
              _buildQuotesSection(context, character),
              _buildImageGallery(context, character),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AnimeCharacter character) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          character.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: character.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.surface,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surface,
                child: const Icon(Icons.person, size: 64),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterHeader(BuildContext context, AnimeCharacter character) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (character.japaneseName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        character.japaneseName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                    if (character.nickname.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '"${character.nickname}"',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildRoleChip(context, character.role),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'From: ${character.animeName}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppConstants.mediumAnimation);
  }

  Widget _buildRoleChip(BuildContext context, String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getRoleColor(role),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'main':
        return Colors.red[600]!;
      case 'supporting':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Widget _buildCharacterInfo(BuildContext context, AnimeCharacter character) {
    final info = [
      if (character.gender != 'Unknown') ('Gender', character.gender),
      if (character.age > 0) ('Age', '${character.age}'),
      if (character.birthday.isNotEmpty) ('Birthday', character.birthday),
      if (character.bloodType.isNotEmpty) ('Blood Type', character.bloodType),
      if (character.height.isNotEmpty) ('Height', character.height),
      if (character.weight.isNotEmpty) ('Weight', character.weight),
      if (character.voiceActor.isNotEmpty)
        ('Voice Actor', character.voiceActor),
    ];

    if (info.isEmpty && character.description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Character Information',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (character.description.isNotEmpty) ...[
            Text(
              character.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (info.isNotEmpty) const SizedBox(height: 16),
          ],
          if (info.isNotEmpty)
            ...info.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '${item.$1}:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.$2,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: AppConstants.mediumAnimation);
  }

  Widget _buildAnimeInfo(
    BuildContext context,
    WidgetRef ref,
    AnimeCharacter character,
  ) {
    if (character.animeName.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Anime Series',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {
                  // Navigate to anime detail screen
                },
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            character.animeName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (character.animeInfo != null) ...[
            const SizedBox(height: 8),
            Text(
              character.animeInfo!.synopsis,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    ).animate(delay: 400.ms).fadeIn(duration: AppConstants.mediumAnimation);
  }

  Widget _buildAbilitiesSection(
    BuildContext context,
    AnimeCharacter character,
  ) {
    if (character.abilities.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Abilities & Skills',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: character.abilities
                .map(
                  (ability) => Chip(
                    label: Text(ability),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ).animate(delay: 600.ms).fadeIn(duration: AppConstants.mediumAnimation);
  }

  Widget _buildQuotesSection(BuildContext context, AnimeCharacter character) {
    if (character.quotes.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Memorable Quotes',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...character.quotes
              .take(3)
              .map(
                (quote) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Text(
                    '"$quote"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
        ],
      ),
    ).animate(delay: 800.ms).fadeIn(duration: AppConstants.mediumAnimation);
  }

  Widget _buildImageGallery(BuildContext context, AnimeCharacter character) {
    if (character.imageUrls.length <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gallery',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: character.imageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: character.imageUrls[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: const Icon(Icons.image, size: 32),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate(delay: 1000.ms).fadeIn(duration: AppConstants.mediumAnimation);
  }

  Widget _buildLoading(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildError(BuildContext context, Object error) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading character: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64),
            SizedBox(height: 16),
            Text('Character not found'),
          ],
        ),
      ),
    );
  }
}
