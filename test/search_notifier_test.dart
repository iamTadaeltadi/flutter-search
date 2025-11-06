import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_search_task/providers/search_providers.dart';
import 'package:flutter_search_task/services/search_service.dart';
import 'package:flutter_search_task/models/search_result.dart';
import 'package:flutter_search_task/models/user.dart';

class ThrowingSearchService extends SearchService {
  ThrowingSearchService() : super(const []);
  @override
  Future<List<SearchResult>> search(String query) async {
    throw Exception('boom');
  }
}

class StubSearchService extends SearchService {
  StubSearchService() : super(const []);
  @override
  Future<List<SearchResult>> search(String query) async {
    return [
      SearchResult(
        user: const User(
          id: '1',
          name: 'Test User',
          username: 'test_user',
          occupation: 'Tester',
          skills: ['QA'],
          rating: 4.0,
          reviewCount: 10,
          avatarUrl: '',
        ),
        matchType: MatchType.username,
        relevanceScore: 100,
      ),
    ];
  }
}

void main() {
  test('SearchNotifier success flow produces data after debounce', () async {
    final container = ProviderContainer(overrides: [
      searchServiceProvider.overrideWithValue(StubSearchService()),
    ]);

    addTearDown(container.dispose);
    final notifier = container.read(searchNotifierProvider.notifier);

    notifier.onQueryChanged('test');
    await Future.delayed(const Duration(milliseconds: 350));

    final state = container.read(searchNotifierProvider);
    expect(state.hasValue, isTrue);
    expect(state.requireValue.allResults, isNotEmpty);
  });

  test('SearchNotifier error flow sets AsyncError and retry recovers', () async {
    final errorContainer = ProviderContainer(overrides: [
      searchServiceProvider.overrideWithValue(ThrowingSearchService()),
    ]);
    addTearDown(errorContainer.dispose);
    final errorNotifier = errorContainer.read(searchNotifierProvider.notifier);

    errorNotifier.onQueryChanged('x');
    await Future.delayed(const Duration(milliseconds: 350));
    expect(errorContainer.read(searchNotifierProvider).hasError, isTrue);

    final okContainer = ProviderContainer(overrides: [
      searchServiceProvider.overrideWithValue(StubSearchService()),
    ]);
    addTearDown(okContainer.dispose);
    final okNotifier = okContainer.read(searchNotifierProvider.notifier);

    okNotifier.onQueryChanged('x');
    await Future.delayed(const Duration(milliseconds: 350));
    final okState = okContainer.read(searchNotifierProvider);
    expect(okState.hasValue, isTrue);
    expect(okState.requireValue.allResults, isNotEmpty);
  });
}


