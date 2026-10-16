import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader(
      {super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child:
                  Text(title, style: Theme.of(context).textTheme.titleLarge)),
          if (action != null)
            TextButton(
                onPressed: onAction,
                child: Text(action!,
                    style: const TextStyle(
                        color: AppColors.orange, fontWeight: FontWeight.w700))),
        ],
      );
}

class Kicker extends StatelessWidget {
  final String text;
  final Color color;
  const Kicker(this.text, {super.key, this.color = AppColors.orange});
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 2));
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  const SurfaceCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(18),
      this.color = AppColors.surface});
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
            color: color,
            border: Border.all(color: AppColors.border.withAlpha(204)),
            borderRadius: BorderRadius.circular(22)),
        child: child,
      );
}

class PrimaryAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool expand;
  const PrimaryAction(
      {super.key,
      required this.label,
      required this.onPressed,
      this.icon = Icons.arrow_forward_rounded,
      this.expand = true});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: expand ? double.infinity : null,
        height: 52,
        child: FilledButton.icon(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: AppColors.bg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))),
          icon: Icon(icon, size: 19),
          label: Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w900)),
        ),
      );
}

class EmptyPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String details;
  final Widget? action;
  const EmptyPanel(
      {super.key,
      required this.icon,
      required this.title,
      required this.details,
      this.action});

  @override
  Widget build(BuildContext context) => SurfaceCard(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(children: [
          Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(21)),
              child: Icon(icon, color: AppColors.orange, size: 31)),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 7),
          Text(details, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ]),
      ));
}

Future<bool> confirmDelete(BuildContext context, String subject) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Delete item?'),
          content: Text('Delete $subject? This action cannot be undone.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete',
                    style: TextStyle(color: Colors.redAccent))),
          ],
        ),
      ) ??
      false;
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String simpleDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
