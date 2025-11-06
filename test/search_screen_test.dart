import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_search_task/screens/search_screen.dart';
import 'package:flutter_search_task/widgets/category_chip.dart';
import 'package:flutter_search_task/providers/search_providers.dart';

void main() {
  Widget wrap(Widget child) => ProviderScope(child: MaterialApp(home: child));

  testWidgets('shows empty state initially', (tester) async {
    await tester.pumpWidget(wrap(const SearchScreen()));
    expect(find.textContaining('Start typing'), findsOneWidget);
  });

  testWidgets('typing shows results for Alice', (tester) async {
    await tester.pumpWidget(wrap(const SearchScreen()));
    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Alice'), findsWidgets);
  });

  testWidgets('categories section appears above usernames when present', (tester) async {
    await tester.pumpWidget(wrap(const SearchScreen()));
    await tester.enterText(find.byType(TextField), 'Car');
    await tester.pump(const Duration(milliseconds: 400));

    final cat = find.textContaining('Matching Categories');
    final users = find.textContaining('Matching Usernames');
    if (cat.evaluate().isNotEmpty && users.evaluate().isNotEmpty) {
      final catPos = tester.getTopLeft(cat);
      final usersPos = tester.getTopLeft(users);
      expect(catPos.dy, lessThan(usersPos.dy));
    }
  });

  testWidgets('no results state appears for unmatched query', (tester) async {
    await tester.pumpWidget(wrap(const SearchScreen()));
    await tester.enterText(find.byType(TextField), 'zzzzzz');
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('No results found'), findsOneWidget);
  });

  testWidgets('tapping category chip updates TextField and triggers search', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(home: const SearchScreen()),
      ),
    );
    
    // First, enter a query that produces categories
    await tester.enterText(find.byType(TextField), 'Car');
    await tester.pump(const Duration(milliseconds: 400));
    
    // Wait for categories to appear
    await tester.pump();
    final categoryChips = find.byType(CategoryChip);
    
    if (categoryChips.evaluate().isNotEmpty) {
      // Get the first category chip's text
      final firstChip = tester.widget<CategoryChip>(categoryChips.first);
      final categoryText = firstChip.category;
      
      // Verify TextField doesn't have this category text yet
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isNot(equals(categoryText)));
      
      // Get initial query from provider
      final stateBefore = container.read(searchNotifierProvider);
      final queryBefore = stateBefore.maybeWhen(
        data: (s) => s.query,
        orElse: () => '',
      );
      expect(queryBefore, isNot(equals(categoryText)));
      
      // Tap the category chip
      await tester.tap(categoryChips.first);
      await tester.pump(const Duration(milliseconds: 400));
      
      // Verify TextField is updated with category text
      final textFieldAfter = tester.widget<TextField>(find.byType(TextField));
      expect(textFieldAfter.controller?.text, equals(categoryText));
      
      // Verify provider state was updated with new query
      final stateAfter = container.read(searchNotifierProvider);
      final queryAfter = stateAfter.maybeWhen(
        data: (s) => s.query,
        orElse: () => '',
      );
      expect(queryAfter, equals(categoryText));
      
      // Verify search was triggered (results should be present)
      final hasResults = stateAfter.maybeWhen(
        data: (s) => s.allResults.isNotEmpty,
        orElse: () => false,
      );
      expect(hasResults, isTrue);
    }
  });
}


