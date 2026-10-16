import 'package:flutter/material.dart';

class Drill {
  final String id;
  final String title;
  final String category;
  final String level;
  final String description;
  final int minutes;
  final List<String> steps;
  final bool isCustom;

  const Drill({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.description,
    required this.minutes,
    required this.steps,
    this.isCustom = false,
  });

  IconData get icon {
    switch (category) {
      case 'Handles':
        return Icons.sports_basketball;
      case 'Shooting':
        return Icons.adjust;
      case 'Footwork':
        return Icons.directions_run;
      case 'Conditioning':
        return Icons.bolt;
      default:
        return Icons.fitness_center;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'level': level,
        'description': description,
        'minutes': minutes,
        'steps': steps,
        'isCustom': isCustom,
      };

  factory Drill.fromJson(Map<String, dynamic> json) => Drill(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Untitled drill',
        category: json['category']?.toString() ?? 'Handles',
        level: json['level']?.toString() ?? 'All levels',
        description: json['description']?.toString() ?? '',
        minutes: (json['minutes'] as num?)?.toInt() ?? 10,
        steps: (json['steps'] as List<dynamic>? ?? [])
            .map((x) => x.toString())
            .toList(),
        isCustom: json['isCustom'] == true,
      );
}

const defaultDrills = <Drill>[
  Drill(
    id: 'handles-01',
    title: 'Handle & Explode',
    category: 'Handles',
    level: 'Intermediate',
    description: 'Build confident handles and a faster first step.',
    minutes: 25,
    steps: [
      'Warm up: stationary pound dribbles, 2 minutes each hand.',
      'Alternate low crossovers, 3 sets of 30 seconds.',
      'Practice between-the-legs and behind-the-back moves, 3 sets.',
      'Attack a cone using one explosive dribble, 10 reps each side.',
      'Cool down with 2 minutes of light ball handling.',
    ],
  ),
  Drill(
    id: 'shoot-01',
    title: 'Form Shooting Lab',
    category: 'Shooting',
    level: 'Beginner',
    description: 'Rebuild your release, balance and follow-through.',
    minutes: 20,
    steps: [
      'Start 1–2 meters from the basket and make 20 one-hand shots.',
      'Add your guide hand for 20 close-range shots.',
      'Shoot 5 makes from each of 5 mid-range spots.',
      'Finish with 10 free throws and track your makes.',
    ],
  ),
  Drill(
    id: 'feet-01',
    title: 'Quick Feet Circuit',
    category: 'Footwork',
    level: 'All levels',
    description: 'Get faster, stay balanced and defend better.',
    minutes: 15,
    steps: [
      'Warm up with easy side steps and ankle circles.',
      'Do defensive slides for 4 sets of 20 seconds.',
      'Practice jump stops and pivot moves for 3 sets of 8.',
      'Perform short closeouts with controlled stops, 3 sets.',
    ],
  ),
  Drill(
    id: 'shoot-02',
    title: 'Catch & Shoot',
    category: 'Shooting',
    level: 'Intermediate',
    description: 'Work on game-speed footwork and quick releases.',
    minutes: 30,
    steps: [
      'Warm up with 15 form shots.',
      'Set your feet and shoot from 5 spots around the arc.',
      'Do 10 catch-and-shoot attempts per spot.',
      'Record your makes and repeat your weakest spot.',
    ],
  ),
  Drill(
    id: 'handles-02',
    title: 'Two-Ball Control',
    category: 'Handles',
    level: 'Advanced',
    description: 'Improve coordination and ball security.',
    minutes: 18,
    steps: [
      'Dribble both balls at the same height for 3 sets of 30 seconds.',
      'Alternate high and low dribbles for 3 sets.',
      'Walk forward and backward while dribbling for 5 minutes.',
      'Finish with stationary crossovers for 2 minutes.',
    ],
  ),
  Drill(
    id: 'cond-01',
    title: 'Fourth Quarter Engine',
    category: 'Conditioning',
    level: 'Intermediate',
    description: 'Practice repeat bursts for late-game energy.',
    minutes: 22,
    steps: [
      'Jog and move dynamically for 5 minutes.',
      'Do court-length runs with walk-back recovery, 6 reps.',
      'Alternate defensive slides and short sprints, 4 rounds.',
      'Walk slowly and stretch comfortably to cool down.',
    ],
  ),
  Drill(
    id: 'feet-02',
    title: 'Triple Threat Moves',
    category: 'Footwork',
    level: 'Beginner',
    description: 'Protect the ball, pivot and create space.',
    minutes: 16,
    steps: [
      'Practice a balanced triple-threat stance for 2 minutes.',
      'Do 10 front pivots and 10 reverse pivots per foot.',
      'Add shot fakes, jab steps and one-dribble attacks.',
      'Combine your favorite moves for 5 minutes.',
    ],
  ),
  Drill(
    id: 'shoot-03',
    title: 'Free Throw Focus',
    category: 'Shooting',
    level: 'All levels',
    description: 'Build a repeatable pre-shot routine.',
    minutes: 12,
    steps: [
      'Choose a simple breathing and dribble routine.',
      'Shoot 5 sets of 10 free throws with the same routine.',
      'Write down your makes after every set.',
      'End by making 3 free throws in a row.',
    ],
  ),
];

class TrainingRecord {
  final String id;
  final String title;
  final String category;
  final int minutes;
  final DateTime completedAt;

  const TrainingRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.minutes,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'minutes': minutes,
        'completedAt': completedAt.toIso8601String(),
      };

  factory TrainingRecord.fromJson(Map<String, dynamic> json) => TrainingRecord(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Session',
        category: json['category']?.toString() ?? 'Training',
        minutes: (json['minutes'] as num?)?.toInt() ?? 0,
        completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}
