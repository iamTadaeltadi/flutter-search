import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_search_task/widgets/search_bar_widget.dart';

void main() {
  Widget host({required ThemeMode mode, ValueChanged<String>? onChanged, VoidCallback? onClear}) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: mode,
      home: Scaffold(
        body: SearchBarWidget(
          controller: TextEditingController(),
          onChanged: onChanged ?? (_) {},
          onClear: onClear,
        ),
      ),
    );
  }

  testWidgets('text color adapts to theme brightness', (tester) async {
    await tester.pumpWidget(host(mode: ThemeMode.dark));
    final textField = tester.widget<TextField>(find.byKey(const Key('search_text_field')));
    final theme = Theme.of(tester.element(find.byKey(const Key('search_text_field'))));
    
    expect(theme.brightness, Brightness.dark);
    expect(textField.style?.color, isNotNull);
    expect(textField.cursorColor, isNotNull);
  });

  testWidgets('light theme uses appropriate text color', (tester) async {
    await tester.pumpWidget(host(mode: ThemeMode.light));
    final textField = tester.widget<TextField>(find.byKey(const Key('search_text_field')));
    final theme = Theme.of(tester.element(find.byKey(const Key('search_text_field'))));
    
    expect(theme.brightness, Brightness.light);
    expect(textField.style?.color, isNotNull);
    expect(textField.style?.color, isNot(equals(theme.colorScheme.onSurface.withOpacity(0.0))));
  });

  testWidgets('onChanged callback fires when typing', (tester) async {
    String? capturedValue;
    await tester.pumpWidget(host(
      mode: ThemeMode.light,
      onChanged: (value) => capturedValue = value,
    ));

    final textField = find.byKey(const Key('search_text_field'));
    await tester.enterText(textField, 'test query');
    await tester.pump();

    expect(capturedValue, equals('test query'));
  });

  testWidgets('clear button appears when text is entered', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchBarWidget(
            controller: controller,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('search_clear_button')), findsNothing);

    await tester.enterText(find.byKey(const Key('search_text_field')), 'test');
    await tester.pump();

    expect(find.byKey(const Key('search_clear_button')), findsOneWidget);
  });

  testWidgets('clear button removes text and calls onClear', (tester) async {
    bool onClearCalled = false;
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchBarWidget(
            controller: controller,
            onChanged: (_) {},
            onClear: () => onClearCalled = true,
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('search_text_field')), 'test');
    await tester.pump();

    expect(controller.text, equals('test'));
    expect(find.byKey(const Key('search_clear_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('search_clear_button')));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(onClearCalled, isTrue);
    expect(find.byKey(const Key('search_clear_button')), findsNothing);
  });

  testWidgets('clear button triggers onChanged with empty string', (tester) async {
    String? lastChangedValue;
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchBarWidget(
            controller: controller,
            onChanged: (value) => lastChangedValue = value,
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('search_text_field')), 'test');
    await tester.pump();
    expect(lastChangedValue, equals('test'));

    await tester.tap(find.byKey(const Key('search_clear_button')));
    await tester.pump();

    expect(lastChangedValue, equals(''));
  });

  testWidgets('hint text color adapts to theme', (tester) async {
    await tester.pumpWidget(host(mode: ThemeMode.dark));
    final textField = tester.widget<TextField>(find.byKey(const Key('search_text_field')));
    final theme = Theme.of(tester.element(find.byKey(const Key('search_text_field'))));
    
    expect(theme.brightness, Brightness.dark);
    expect(textField.decoration?.hintStyle?.color, isNotNull);
  });
}
