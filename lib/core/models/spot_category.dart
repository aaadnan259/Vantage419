import 'package:flutter/material.dart';

/// Categories for Toledo spots, each with display metadata.
enum SpotCategory {
  dining(
    displayName: 'Dining',
    icon: Icons.restaurant_rounded,
    color: Color(0xFFFF6B6B),
  ),
  recreation(
    displayName: 'Recreation',
    icon: Icons.park_rounded,
    color: Color(0xFF4ECDC4),
  ),
  fitness(
    displayName: 'Fitness',
    icon: Icons.fitness_center_rounded,
    color: Color(0xFF45B7D1),
  ),
  cafe(
    displayName: 'Café',
    icon: Icons.coffee_rounded,
    color: Color(0xFFDDA15E),
  ),
  entertainment(
    displayName: 'Entertainment',
    icon: Icons.theater_comedy_rounded,
    color: Color(0xFFFFE66D),
  );

  const SpotCategory({
    required this.displayName,
    required this.icon,
    required this.color,
  });

  final String displayName;
  final IconData icon;
  final Color color;
}
