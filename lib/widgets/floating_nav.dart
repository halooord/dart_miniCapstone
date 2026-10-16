import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FloatingNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;
  const FloatingNav(
      {super.key, required this.selected, required this.onSelected});

  static const tabs = <(String, IconData, IconData)>[
    ('Home', Icons.home_outlined, Icons.home_rounded),
    ('Train', Icons.sports_basketball_outlined, Icons.sports_basketball),
    ('Progress', Icons.bar_chart_outlined, Icons.bar_chart_rounded),
    ('Community', Icons.groups_outlined, Icons.groups_rounded),
    ('Profile', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 78,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xF0232630),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF444853), width: 1),
            ),
            child: Row(children: [
              for (int index = 0; index < tabs.length; index++)
                Expanded(
                    child: Semantics(
                  button: true,
                  selected: selected == index,
                  label: '${tabs[index].$1} tab',
                  child: InkWell(
                    key: Key('nav_${tabs[index].$1.toLowerCase()}'),
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => onSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: selected == index
                            ? AppColors.orange.withAlpha(33)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                selected == index
                                    ? tabs[index].$3
                                    : tabs[index].$2,
                                color: selected == index
                                    ? AppColors.orange
                                    : AppColors.muted,
                                size: 22),
                            const SizedBox(height: 4),
                            FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(tabs[index].$1,
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: selected == index
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: selected == index
                                            ? AppColors.orange
                                            : AppColors.muted))),
                          ]),
                    ),
                  ),
                )),
            ]),
          ),
        ),
      );
}
