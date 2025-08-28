import 'package:flutter/material.dart';

class CharacterDetailScreen extends StatelessWidget {
  final String characterId;

  const CharacterDetailScreen({super.key, required this.characterId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Character Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 64),
            const SizedBox(height: 16),
            Text('Character ID: $characterId'),
            const Text('Character Details Coming Soon!'),
          ],
        ),
      ),
    );
  }
}
