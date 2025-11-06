import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_search_task/screens/about_screen.dart';
import 'package:flutter_search_task/providers/theme_provider.dart';

void main() {
  testWidgets('About shows Appearance section', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: AboutScreen())));
    await tester.pump();
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('About'), findsWidgets);
  });

  testWidgets('tapping Dark chip updates themeModeProvider', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: container.read(themeModeProvider),
          home: const AboutScreen(),
        ),
      ),
    );
    await tester.pump();

    final initialMode = container.read(themeModeProvider);

    final darkChip = find.text('Dark');
    expect(darkChip, findsOneWidget);
    await tester.tap(darkChip);
    await tester.pump(const Duration(milliseconds: 200));

    final modeAfter = container.read(themeModeProvider);
    expect(modeAfter, ThemeMode.dark);
    expect(modeAfter, isNot(equals(initialMode)));
  });

  testWidgets('MaterialApp uses dark theme when themeMode is dark', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: container.read(themeModeProvider),
          home: const AboutScreen(),
        ),
      ),
    );
    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    expect(theme.brightness, Brightness.dark);
  });

  testWidgets('tapping Light chip updates themeModeProvider', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: container.read(themeModeProvider),
          home: const AboutScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(container.read(themeModeProvider), ThemeMode.dark);

    final lightChip = find.text('Light');
    expect(lightChip, findsOneWidget);
    await tester.tap(lightChip);
    await tester.pump(const Duration(milliseconds: 200));

    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  testWidgets('tapping System chip updates themeModeProvider', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(themeModeProvider.notifier).setMode(ThemeMode.light);
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: container.read(themeModeProvider),
          home: const AboutScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(container.read(themeModeProvider), ThemeMode.light);

    final systemChip = find.text('System');
    expect(systemChip, findsOneWidget);
    await tester.tap(systemChip);
    await tester.pump(const Duration(milliseconds: 200));

    expect(container.read(themeModeProvider), ThemeMode.system);
  });
}
