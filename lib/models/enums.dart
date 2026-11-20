import 'package:flutter/material.dart';

/// The five parts of the user's life the app tracks. Told apart by icon and a
/// small label, never by a rainbow of colours (see [LifeAreaStyle]).
enum LifeArea {
  startup('Startup', Icons.rocket_launch_rounded),
  cloud('Cloud Learning', Icons.cloud_rounded),
  sideGigs('Side Gigs', Icons.content_cut_rounded),
  health('Health', Icons.favorite_rounded),
  personal('Personal', Icons.self_improvement_rounded);

  const LifeArea(this.label, this.icon);
  final String label;
  final IconData icon;

  String get short => switch (this) {
        LifeArea.startup => 'Startup',
        LifeArea.cloud => 'Cloud',
        LifeArea.sideGigs => 'Gigs',
        LifeArea.health => 'Health',
        LifeArea.personal => 'Personal',
      };
}

enum TaskStatus { todo, inProgress, done, snoozed }

enum GoalStatus { active, paused, achieved }

enum BlockType {
  focus('Focus', Icons.bolt_rounded),
  breakTime('Break', Icons.local_cafe_rounded),
  admin('Admin', Icons.inbox_rounded),
  rest('Rest', Icons.bedtime_rounded),
  fixed('Fixed', Icons.lock_clock_rounded);

  const BlockType(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum RepeatRule {
  none('Once'),
  daily('Every day'),
  weekdays('Weekdays'),
  weekly('Every week');

  const RepeatRule(this.label);
  final String label;
}

/// How heavy a task feels. Used to pick easy wins on low-energy days and the
/// hardest thing first on high-energy days.
enum Effort {
  light('Light'),
  medium('Medium'),
  heavy('Heavy');

  const Effort(this.label);
  final String label;
}
