import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:court_iq/main.dart';
import 'package:court_iq/services/app_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('five navigation tabs are displayed', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = AppStore();
    await store.load();
    await tester.pumpWidget(CourtIqApp(store: store));

    expect(find.byKey(const Key('nav_home')), findsOneWidget);
    expect(find.byKey(const Key('nav_train')), findsOneWidget);
    expect(find.byKey(const Key('nav_progress')), findsOneWidget);
    expect(find.byKey(const Key('nav_community')), findsOneWidget);
    expect(find.byKey(const Key('nav_profile')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav_train')));
    await tester.pumpAndSettle();
    expect(find.text('TRAINING LAB'), findsOneWidget);
  });
}
