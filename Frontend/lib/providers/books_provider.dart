import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookswap/core/dio_client.dart';
import 'package:dio/dio.dart';

class BooksState {
  final bool isLoading;
  final String? error;
  final List<dynamic> books;
  final List<dynamic> userBooks;
  final List<dynamic> sentSwapRequests;
  final List<dynamic> receivedSwapRequests;

  BooksState({
    this.isLoading = false,
    this.error,
    this.books = const [],
    this.userBooks = const [],
    this.sentSwapRequests = const [],
    this.receivedSwapRequests = const [],
  });

  BooksState copyWith({
    bool? isLoading,
    String? error,
    List<dynamic>? books,
    List<dynamic>? userBooks,
    List<dynamic>? sentSwapRequests,
    List<dynamic>? receivedSwapRequests,
  }) {
    return BooksState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      books: books ?? this.books,
      userBooks: userBooks ?? this.userBooks,
      sentSwapRequests: sentSwapRequests ?? this.sentSwapRequests,
      receivedSwapRequests: receivedSwapRequests ?? this.receivedSwapRequests,
    );
  }
}

class BooksNotifier extends StateNotifier<BooksState> {
  BooksNotifier() : super(BooksState());

  Future<void> fetchBooks({String? searchQuery}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await DioClient.dio.get(
        '/books',
        queryParameters: searchQuery != null && searchQuery.isNotEmpty
            ? {'search': searchQuery}
            : null,
      );
      final data = response.data as List<dynamic>? ?? [];
      state = state.copyWith(isLoading: false, books: data);
    } catch (e) {
      String msg = 'Failed to load books.';
      if (e is DioException) {
        msg = e.response?.data?['message'] ?? msg;
      }
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  Future<void> fetchUserBooks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await DioClient.dio.get('/books/my-books');
      final data = response.data as List<dynamic>? ?? [];
      state = state.copyWith(isLoading: false, userBooks: data);
    } catch (e) {
      String msg = 'Failed to load user books.';
      if (e is DioException) {
        msg = e.response?.data?['message'] ?? msg;
      }
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await DioClient.dio.delete('/books/$bookId');
      await fetchUserBooks();
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> updateBook(String bookId, Map<String, dynamic> data) async {
    try {
      await DioClient.dio.put('/books/$bookId', data: data);
      await fetchUserBooks();
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> requestSwap(Map<String, dynamic> data) async {
    try {
      await DioClient.dio.post('/swap-requests', data: data);
      await fetchSwapRequests();
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> fetchSwapRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sentRes = await DioClient.dio.get('/swap-requests/sent');
      final recRes = await DioClient.dio.get('/swap-requests/received');
      state = state.copyWith(
        isLoading: false,
        sentSwapRequests: sentRes.data as List<dynamic>? ?? [],
        receivedSwapRequests: recRes.data as List<dynamic>? ?? [],
      );
    } catch (e) {
      String msg = 'Failed to load swap requests.';
      if (e is DioException) {
        msg = e.response?.data?['message'] ?? msg;
      }
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  Future<void> handleSwapRequest(String requestId, bool accept) async {
    try {
      final status = accept ? 'accepted' : 'rejected';
      await DioClient.dio.patch('/swap-requests/$requestId', data: {'status': status});
      await fetchSwapRequests();
    } catch (e) {
      // Handle error if needed
    }
  }
}

final booksProvider = StateNotifierProvider<BooksNotifier, BooksState>((ref) {
  return BooksNotifier();
});
