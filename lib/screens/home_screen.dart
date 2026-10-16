import 'package:flutter/material.dart';
import '../models/training.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';
import 'workout_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppStore store;
  final ValueChanged<int> onNavigate;
  const HomeScreen({super.key, required this.store, required this.onNavigate});

  Future<void> _openWorkout(BuildContext context, Drill drill) async {
    final completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => WorkoutScreen(drill: drill, store: store)));
    if (completed == true && context.mounted) {
      showMessage(context, 'Workout saved! Keep building your game.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstName = store.athleteName.trim().split(' ').first;
    return ListView(
      key: const Key('home_scroll'),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
      children: [
        const Kicker('Your daily training hub', color: AppColors.orangeSoft),
        const SizedBox(height: 10),
        Text('LET’S GET TO WORK,',
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(fontSize: 29)),
        Text('${firstName.toUpperCase()}.',
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(color: AppColors.orange)),
        const SizedBox(height: 8),
        const Text('Small improvements. Big game energy.'),
        const SizedBox(height: 22),
        _FeatureCard(onStart: () => _openWorkout(context, defaultDrills.first)),
        const SizedBox(height: 21),
        Row(children: [
          Expanded(
              child: _MetricTile(
                  label: 'SESSIONS',
                  value: '${store.totalSessions}',
                  icon: Icons.sports_score)),
          const SizedBox(width: 11),
          Expanded(
              child: _MetricTile(
                  label: 'MINUTES',
                  value: '${store.totalMinutes}',
                  icon: Icons.timer_outlined)),
          const SizedBox(width: 11),
          Expanded(
              child: _MetricTile(
                  label: 'THIS WEEK',
                  value: '${store.weeklySessions}',
                  icon: Icons.local_fire_department_outlined)),
        ]),
        const SizedBox(height: 22),
        SurfaceCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.bolt_rounded, color: AppColors.orange, size: 24),
            const SizedBox(width: 7),
            Expanded(
                child: Text('Weekly goal',
                    style: Theme.of(context).textTheme.titleMedium)),
            Text('${store.weeklySessions} / ${store.weeklyGoal}',
                style: const TextStyle(
                    color: AppColors.orange,
                    fontWeight: FontWeight.w800,
                    fontSize: 18)),
          ]),
          const SizedBox(height: 13),
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: store.weeklyProgress,
                minHeight: 9,
                backgroundColor: AppColors.surfaceAlt,
                color: AppColors.orange,
              )),
          const SizedBox(height: 10),
          Text(store.weeklySessions >= store.weeklyGoal
              ? 'Goal crushed! You earned this week.'
              : '${store.weeklyGoal - store.weeklySessions} more session(s) to hit your weekly target.'),
        ])),
        const SizedBox(height: 22),
        SectionHeader(
            title: 'Made for your game',
            action: 'View all',
            onAction: () => onNavigate(1)),
        const SizedBox(height: 11),
        ...defaultDrills.skip(1).take(2).map((drill) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _openWorkout(context, drill),
                borderRadius: BorderRadius.circular(20),
                child: SurfaceCard(
                    child: Row(children: [
                  Container(
                      width: 51,
                      height: 51,
                      decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(15)),
                      child:
                          Icon(drill.icon, color: AppColors.orange, size: 26)),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(drill.title,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 3),
                        Text('${drill.category}  •  ${drill.minutes} min',
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ])),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.muted, size: 16),
                ])),
              ),
            )),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MetricTile(
      {required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: AppColors.orange, size: 19),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(label,
              maxLines: 1,
              style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
        ]),
      );
}

class _FeatureCard extends StatelessWidget {
  final VoidCallback onStart;
  const _FeatureCard({required this.onStart});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: SizedBox(
            height: 300,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset('assets/images/hero_training.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: AppColors.surfaceAlt)),
              const DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                colors: [
                  Color(0xE80D0E15),
                  Color(0xBB0D0E15),
                  Color(0x110D0E15)
                ],
                stops: [0, .51, 1],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ))),
              Padding(
                padding: const EdgeInsets.all(23),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.orange)),
                        const SizedBox(width: 7),
                        const Kicker("Today's session", color: AppColors.text),
                      ]),
                      const SizedBox(height: 16),
                      const Text('HANDLE\n& EXPLODE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              height: 1.01,
                              letterSpacing: -1.0)),
                      const SizedBox(height: 8),
                      const Text('25 MIN   •   INTERMEDIATE',
                          style: TextStyle(
                              color: Color(0xFFDBDBDF),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4)),
                      const Spacer(),
                      SizedBox(
                          width: 188,
                          child: PrimaryAction(
                              label: 'Start training',
                              icon: Icons.play_arrow_rounded,
                              onPressed: onStart)),
                    ]),
              ),
            ])),
      );
}
