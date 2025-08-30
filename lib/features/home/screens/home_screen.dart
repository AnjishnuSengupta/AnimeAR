import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../widgets/character_card.dart';
import '../widgets/feature_card.dart';
import '../widgets/stats_overview.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final authUser = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppConstants.settingsRoute),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh user data and recommendations
          ref.invalidate(userProfileProvider);
          ref.invalidate(authStateProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(context, userProfile, authUser),
              const SizedBox(height: 24),
              _buildStatsSection(userProfile),
              const SizedBox(height: 24),
              _buildFeaturesSection(context),
              const SizedBox(height: 24),
              _buildRecentDiscoveriesSection(),
              const SizedBox(height: 24),
              _buildRecommendationsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(
    BuildContext context,
    AsyncValue userProfile,
    AsyncValue authUser,
  ) {
    return userProfile.when(
      data: (profileData) {
        final userName =
            profileData?.displayName ??
            (authUser.value?.displayName) ??
            (authUser.value?.email?.split('@')[0]) ??
            'Explorer';
        return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  userName,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready to discover new anime characters?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            )
            .animate()
            .fadeIn(duration: AppConstants.mediumAnimation)
            .slideY(begin: -0.2, end: 0);
      },
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Text('Error: $error'),
    );
  }

  Widget _buildStatsSection(AsyncValue userProfile) {
    return userProfile.when(
      data: (profileData) =>
          StatsOverview(
                level: 1, // Default level for now
                experiencePoints: 0, // Default XP for now
                discoveredCount: profileData?.discoveredLocationsCount ?? 0,
                favoritesCount: profileData?.favoriteCharacters.length ?? 0,
              )
              .animate(delay: 200.ms)
              .fadeIn(duration: AppConstants.mediumAnimation)
              .slideY(begin: 0.2, end: 0),
      loading: () => const SizedBox.shrink(),
      error: (_, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore Features',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    icon: Icons.camera_alt,
                    title: 'AR Camera',
                    subtitle: 'Scan & Discover',
                    onTap: () => context.go(AppConstants.arCameraRoute),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.bookmark_border,
                    title: 'Collection',
                    subtitle: 'View Discovered',
                    onTap: () => context.push(AppConstants.collectionRoute),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    icon: Icons.engineering,
                    title: 'Camera Test',
                    subtitle: 'Test Camera Setup',
                    onTap: () => context.push('/camera-test'),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(child: SizedBox()), // Placeholder for balance
              ],
            ),
          ],
        )
        .animate(delay: 400.ms)
        .fadeIn(duration: AppConstants.mediumAnimation)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildRecentDiscoveriesSection() {
    return Builder(
      builder: (context) =>
          Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Discoveries',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to full discoveries list
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5, // Placeholder count
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: index < 4 ? 16 : 0),
                          child: CharacterCard(
                            imageUrl: 'https://via.placeholder.com/150x200',
                            name: 'Character ${index + 1}',
                            anime: 'Anime Series',
                            onTap: () {
                              // Navigate to character detail
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
              .animate(delay: 600.ms)
              .fadeIn(duration: AppConstants.mediumAnimation)
              .slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildRecommendationsSection() {
    return Builder(
      builder: (context) =>
          Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended for You',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: 4, // Placeholder count
                    itemBuilder: (context, index) {
                      return CharacterCard(
                        imageUrl: 'https://via.placeholder.com/150x200',
                        name: 'Recommended ${index + 1}',
                        anime: 'Popular Anime',
                        onTap: () {
                          // Navigate to character detail
                        },
                      );
                    },
                  ),
                ],
              )
              .animate(delay: 800.ms)
              .fadeIn(duration: AppConstants.mediumAnimation)
              .slideY(begin: 0.2, end: 0),
    );
  }
}
