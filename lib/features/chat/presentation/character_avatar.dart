import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/entities/chat_character.dart';

class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({super.key, required this.character, this.radius = 20});

  final ChatCharacter? character;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final imagePath = character?.imagePath;
    final hasImage = imagePath != null && File(imagePath).existsSync();
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      backgroundImage: hasImage ? FileImage(File(imagePath)) : null,
      child: hasImage
          ? null
          : Text(
              _initials(character?.name),
              style: TextStyle(
                fontSize: radius * 0.62,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}

String _initials(String? name) {
  final parts = (name ?? 'AI')
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'AI';
  }
  if (parts.length == 1) {
    return parts.first.characters.take(2).toString().toUpperCase();
  }
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}
