import 'package:flutter/material.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class ProfileScreen extends StatelessWidget {
  final AppStore store;
  const ProfileScreen({super.key, required this.store});

  Future<void> changeName(BuildContext context) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(initialName: store.athleteName),
    );
    if (!context.mounted || newName == null) return;
    try {
      await store.updateName(newName);
      if (context.mounted) showMessage(context, 'Profile updated.');
    } catch (_) {
      if (context.mounted) showMessage(context, 'Could not update your name.');
    }
  }

  Future<void> resetData(BuildContext context) async {
    if (!await confirmDelete(
        context, 'all training history and custom drills')) {
      return;
    }
    if (!context.mounted) return;
    try {
      await store.clearUserData();
      if (context.mounted) {
        showMessage(context, 'Your local training data was cleared.');
      }
    } catch (_) {
      if (context.mounted) {
        showMessage(context, 'Unable to clear data. Try again.');
      }
    }
  }

  Future<void> changeGoal(BuildContext context, int newGoal) async {
    try {
      await store.updateWeeklyGoal(newGoal);
    } catch (_) {
      if (context.mounted)
        // ignore: curly_braces_in_flow_control_structures
        showMessage(context, 'Could not save the weekly goal.');
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(22, 15, 22, 24),
        children: [
          const Kicker('This is your court'),
          const SizedBox(height: 9),
          Text('ATHLETE PROFILE',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 21),
          SurfaceCard(
              child: Row(children: [
            Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(22)),
                child: const Icon(Icons.person_rounded,
                    size: 40, color: AppColors.orange)),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(store.athleteName,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  const Text('Always working on the game'),
                ])),
            IconButton(
                tooltip: 'Edit name',
                onPressed: () => changeName(context),
                icon: const Icon(Icons.edit_outlined, color: AppColors.orange)),
          ])),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Your numbers'),
          const SizedBox(height: 10),
          SurfaceCard(
              child: Column(children: [
            _InfoRow(
                icon: Icons.sports_basketball_outlined,
                label: 'Total workouts',
                value: '${store.totalSessions}'),
            const Divider(height: 24),
            _InfoRow(
                icon: Icons.schedule_outlined,
                label: 'Training minutes',
                value: '${store.totalMinutes}'),
            const Divider(height: 24),
            _InfoRow(
                icon: Icons.library_add_check_outlined,
                label: 'Custom drills',
                value: '${store.customDrills.length}'),
          ])),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Weekly target'),
          const SizedBox(height: 10),
          SurfaceCard(
              child: Row(children: [
            const Icon(Icons.flag_outlined, color: AppColors.orange, size: 26),
            const SizedBox(width: 13),
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Sessions per week',
                      style: TextStyle(
                          color: AppColors.text, fontWeight: FontWeight.w700)),
                  Text('Set a goal that fits your schedule',
                      style: TextStyle(fontSize: 11)),
                ])),
            IconButton(
                onPressed: store.weeklyGoal > 1
                    ? () => changeGoal(context, store.weeklyGoal - 1)
                    : null,
                tooltip: 'Lower goal',
                icon: const Icon(Icons.remove_circle_outline)),
            Text('${store.weeklyGoal}',
                style: const TextStyle(
                    color: AppColors.orange,
                    fontWeight: FontWeight.w900,
                    fontSize: 20)),
            IconButton(
                onPressed: store.weeklyGoal < 7
                    ? () => changeGoal(context, store.weeklyGoal + 1)
                    : null,
                tooltip: 'Raise goal',
                icon: const Icon(Icons.add_circle_outline)),
          ])),
          const SizedBox(height: 20),
          const SectionHeader(title: 'App information'),
          const SizedBox(height: 10),
          const SurfaceCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                _InfoRow(
                    icon: Icons.phone_iphone_rounded,
                    label: 'App',
                    value: 'Court IQ · v1.0'),
                Divider(height: 24),
                _InfoRow(
                    icon: Icons.cloud_outlined,
                    label: 'News feed',
                    value: 'ESPN NBA API'),
                Divider(height: 24),
                Text(
                    'Your sessions, goals and custom drills are stored locally on this device. '
                    'News requires an internet connection; offline examples are clearly labeled.',
                    style: TextStyle(
                        color: AppColors.muted, fontSize: 12, height: 1.5)),
              ])),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => resetData(context),
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Color(0xFF6B3540)),
                padding: const EdgeInsets.symmetric(vertical: 15)),
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text('Clear training history & custom drills'),
          ),
          const SizedBox(height: 15),
          const Center(
              child: Text('MADE FOR THE LOVE OF THE GAME',
                  style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      letterSpacing: 1.5))),
        ],
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: AppColors.orange, size: 20),
        const SizedBox(width: 11),
        Expanded(
            child: Text(label,
                style: const TextStyle(color: AppColors.text, fontSize: 13))),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.orangeSoft,
                fontSize: 12)),
      ]);
}

/// Dialog that owns its TextEditingController until Flutter removes the route.
class _NameDialog extends StatefulWidget {
  final String initialName;
  const _NameDialog({required this.initialName});

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void save() {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context, controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit athlete name'),
        content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              maxLength: 28,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Your name'),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Please enter a name' : null,
              onFieldSubmitted: (_) => save(),
            )),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(onPressed: save, child: const Text('Save')),
        ],
      );
}
