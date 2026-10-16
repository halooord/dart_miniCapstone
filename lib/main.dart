import 'package:flutter/material.dart';
import 'screens/community_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/train_screen.dart';
import 'services/app_store.dart';
import 'theme/app_theme.dart';
import 'widgets/floating_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.load();
  runApp(CourtIqApp(store: store));
}

class CourtIqApp extends StatelessWidget {
  final AppStore store;
  const CourtIqApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Court IQ | Basketball Training',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    home: MainShell(store: store),
  );
}

class MainShell extends StatefulWidget {
  final AppStore store;
  const MainShell({super.key, required this.store});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentTab = 0;

  void switchTab(int index) => setState(() => currentTab = index);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        // Build pages inside the listener so screens refresh on store changes.
        final pages = [
          HomeScreen(store: widget.store, onNavigate: switchTab),
          TrainScreen(store: widget.store),
          ProgressScreen(store: widget.store, onTrain: () => switchTab(1)),
          CommunityScreen(active: currentTab == 3),
          ProfileScreen(store: widget.store),
        ];
        return Scaffold(
          appBar: AppBar(
              toolbarHeight: 64,
              titleSpacing: 23,
              title: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  height: 30, width: 30,
                  decoration: BoxDecoration(color: AppColors.orange,
                    borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.sports_basketball, color: AppColors.bg, size: 22),
                ),
                const SizedBox(width: 10),
                const Text('COURT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.6)),
                const Text(' IQ', style: TextStyle(color: AppColors.orange,
                  fontWeight: FontWeight.w900, letterSpacing: 1.6)),
              ]),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Tooltip(
                    message: 'Your training profile',
                    child: IconButton(
                      onPressed: () => switchTab(4),
                      icon: const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.surfaceAlt,
                        child: Icon(Icons.person_outline, color: AppColors.orange, size: 21),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Stack(children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 95),
                    child: IndexedStack(index: currentTab, children: pages),
                  ),
                ),
                Positioned(
                  left: 18, right: 18, bottom: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(28),
                      boxShadow: const [BoxShadow(color: Color(0x99000000),
                        blurRadius: 28, spreadRadius: 7, offset: Offset(0, 12))]),
                    child: FloatingNav(selected: currentTab, onSelected: switchTab),
                  ),
                ),
              ]),
            ),
        );
      },
    );
  }
}
