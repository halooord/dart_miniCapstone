import 'dart:async';
import 'package:flutter/material.dart';
import '../models/training.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class WorkoutScreen extends StatefulWidget {
  final Drill drill;
  final AppStore store;
  const WorkoutScreen({super.key, required this.drill, required this.store});
  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with WidgetsBindingObserver {
  Timer? timer;
  DateTime? endsAt;
  late int secondsRemaining;
  bool isRunning = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    secondsRemaining = widget.drill.minutes * 60;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    super.dispose();
  }

  /// Refreshes using actual wall-clock elapsed time, not just timer callbacks.
  /// This is more accurate when Android pauses callbacks in the background.
  void syncClock() {
    if (!mounted || !isRunning || endsAt == null) return;
    final ms = endsAt!.difference(DateTime.now()).inMilliseconds;
    final updatedSeconds = ms <= 0 ? 0 : (ms + 999) ~/ 1000;
    if (updatedSeconds == 0) {
      timer?.cancel();
      endsAt = null;
      setState(() {
        secondsRemaining = 0;
        isRunning = false;
      });
      showMessage(context, 'Timer complete! Log your training session.');
    } else if (secondsRemaining != updatedSeconds) {
      setState(() => secondsRemaining = updatedSeconds);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) syncClock();
  }

  void toggleTimer() {
    if (isRunning) {
      syncClock();
      timer?.cancel();
      endsAt = null;
      if (mounted) setState(() => isRunning = false);
    } else {
      if (secondsRemaining == 0) secondsRemaining = widget.drill.minutes * 60;
      endsAt = DateTime.now().add(Duration(seconds: secondsRemaining));
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (_) => syncClock());
      setState(() => isRunning = true);
    }
  }

  void resetTimer() {
    timer?.cancel();
    endsAt = null;
    setState(() {
      isRunning = false;
      secondsRemaining = widget.drill.minutes * 60;
    });
  }

  Future<void> completeWorkout() async {
    if (isSaving) return;
    setState(() => isSaving = true);
    try {
      await widget.store.addSession(widget.drill);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() => isSaving = false);
        showMessage(context, 'Unable to save this workout. Try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final drill = widget.drill;
    final time =
        '${(secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(secondsRemaining % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(
          title: const Text('TRAINING SESSION'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context, false))),
      body: SafeArea(
          child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
        children: [
          Kicker(drill.category),
          const SizedBox(height: 12),
          Text(drill.title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 9),
          Text(drill.description),
          const SizedBox(height: 17),
          Wrap(spacing: 9, runSpacing: 8, children: [
            Chip(
                label: Text('${drill.minutes} minutes'),
                avatar: const Icon(Icons.timer_outlined, size: 17)),
            Chip(
                label: Text(drill.level),
                avatar: const Icon(Icons.stars_outlined, size: 17)),
          ]),
          const SizedBox(height: 23),
          SurfaceCard(
              child: Column(children: [
            const Kicker('Session timer'),
            const SizedBox(height: 10),
            Text(time,
                key: const Key('session_timer'),
                style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 58,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              FilledButton.icon(
                  onPressed: toggleTimer,
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: AppColors.bg),
                  icon: Icon(isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded),
                  label: Text(isRunning ? 'Pause' : 'Start timer')),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                  onPressed: resetTimer,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset')),
            ]),
          ])),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Your drill plan'),
          const SizedBox(height: 12),
          ...drill.steps.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SurfaceCard(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.surfaceAlt,
                          child: Text('${entry.key + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.orange,
                                  fontSize: 12))),
                      const SizedBox(width: 13),
                      Expanded(
                          child: Text(entry.value,
                              style: const TextStyle(
                                  height: 1.45,
                                  color: AppColors.text,
                                  fontSize: 14))),
                    ])),
              )),
          const SizedBox(height: 13),
          const Text(
              'Only log the session after you actually finish the workout.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12)),
          const SizedBox(height: 13),
          PrimaryAction(
              key: const Key('complete_workout'),
              label: isSaving ? 'Saving...' : 'Complete & save workout',
              icon: Icons.check_circle_outline_rounded,
              onPressed: isSaving ? null : completeWorkout),
        ],
      )),
    );
  }
}
