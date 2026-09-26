import 'package:flutter_test/flutter_test.dart';
import 'package:bookswap/providers/books_provider.dart';

void main() {
  group('Book Management Unit Tests', () {
    test('initial books state defaults', () {
      final state = BooksState();
      expect(state.books, isEmpty);
      expect(state.sentSwapRequests, isEmpty);
      expect(state.receivedSwapRequests, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('BooksState copyWith retains unmodified fields', () {
      final state = BooksState();
      final updated = state.copyWith(
        books: [
          {'_id': '1', 'title': 'Clean Code'}
        ],
        isLoading: true,
      );

      expect(updated.books.length, 1);
      expect(updated.books.first['title'], 'Clean Code');
      expect(updated.isLoading, true);
      expect(updated.error, isNull);
    });
  });
}
