import 'package:flutter/material.dart';
import '../models/training.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class ProgressScreen extends StatelessWidget {
  final AppStore store;
  final VoidCallback onTrain;
  const ProgressScreen({super.key, required this.store, required this.onTrain});

  Future<void> _deleteRecord(
      BuildContext context, TrainingRecord record) async {
    if (!await confirmDelete(context, 'this ${record.title} session')) return;
    if (!context.mounted) return;
    try {
      await store.deleteSession(record.id);
      if (context.mounted) {
        showMessage(context, 'Session deleted from your history.');
      }
    } catch (_) {
      if (context.mounted) {
        showMessage(context, 'Could not delete this session.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final weekDays = List.generate(
        7,
        (i) => DateTime(today.year, today.month, today.day)
            .subtract(Duration(days: 6 - i)));
    final dayCounts = weekDays.map(store.sessionsOn).toList();
    final maxCount = dayCounts.fold(1, (int max, int n) => n > max ? n : max);
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 15, 22, 24),
      children: [
        const Kicker('Work speaks louder'),
        const SizedBox(height: 9),
        Text('YOUR PROGRESS',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text('Every workout counts. Watch the work add up.'),
        const SizedBox(height: 21),
        Row(children: [
          Expanded(
              child: _ProgressStat(
                  label: 'WORKOUTS',
                  value: '${store.totalSessions}',
                  icon: Icons.fitness_center)),
          const SizedBox(width: 12),
          Expanded(
              child: _ProgressStat(
                  label: 'TOTAL MINUTES',
                  value: '${store.totalMinutes}',
                  icon: Icons.av_timer_rounded)),
        ]),
        const SizedBox(height: 13),
        SurfaceCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Kicker('Last 7 days'),
                  const SizedBox(height: 6),
                  Text('Training activity',
                      style: Theme.of(context).textTheme.titleLarge),
                ])),
            Text('${dayCounts.fold(0, (a, b) => a + b)} workouts',
                style: const TextStyle(
                    color: AppColors.orange, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 26),
          SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                    7,
                    (i) => Expanded(
                            child: Column(children: [
                          Expanded(
                              child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: dayCounts[i] == 0
                                  ? 0.05
                                  : dayCounts[i] / maxCount,
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                    gradient: dayCounts[i] == 0
                                        ? null
                                        : const LinearGradient(
                                            colors: [
                                                AppColors.orangeSoft,
                                                AppColors.orange
                                              ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter),
                                    color: dayCounts[i] == 0
                                        ? AppColors.surfaceAlt
                                        : null,
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          )),
                          const SizedBox(height: 10),
                          Text(dayNames[weekDays[i].weekday - 1],
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 12)),
                        ]))),
              )),
          const SizedBox(height: 9),
          const Text('Bar height represents completed sessions per day.',
              style: TextStyle(fontSize: 11)),
        ])),
        const SizedBox(height: 23),
        const SectionHeader(title: 'Training history'),
        const SizedBox(height: 11),
        if (store.records.isEmpty)
          EmptyPanel(
            icon: Icons.insights_outlined,
            title: 'Your journey starts here',
            details:
                'Finish your first drill to see your sessions and activity chart update.',
            action: SizedBox(
                width: 180,
                child:
                    PrimaryAction(label: 'Browse drills', onPressed: onTrain)),
          )
        else
          ListView.builder(
            key: const Key('session_history'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: store.records.length,
            itemBuilder: (context, index) {
              final record = store.records[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SurfaceCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 9, 12),
                  child: Row(children: [
                    const CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.surfaceAlt,
                        child: Icon(Icons.check_rounded,
                            color: AppColors.success)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(record.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text(
                              '${simpleDate(record.completedAt)}  •  ${record.minutes} min',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.muted)),
                        ])),
                    IconButton(
                        key: Key('delete_session_${record.id}'),
                        tooltip: 'Delete session',
                        onPressed: () => _deleteRecord(context, record),
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 20, color: Colors.redAccent)),
                  ]),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _ProgressStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _ProgressStat(
      {required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => SurfaceCard(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.orange, size: 24),
          const SizedBox(height: 16),
          Text(value,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 31,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  letterSpacing: 1)),
        ],
      ));
}
