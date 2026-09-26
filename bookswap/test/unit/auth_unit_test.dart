import 'package:flutter_test/flutter_test.dart';
import 'package:bookswap/providers/auth_provider.dart';

void main() {
  group('Authentication Unit Tests', () {
    test('initial state has unauthenticated defaults', () {
      const state = AuthState();
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.user, isNull);
      expect(state.users, isEmpty);
      expect(state.isAdminRegistered, false);
    });

    test('copyWith updates fields immutably', () {
      const state = AuthState();
      final updated = state.copyWith(
        isAuthenticated: true,
        user: {'name': 'Alice', 'email': 'alice@test.com'},
        error: 'Test Error',
      );

      expect(updated.isAuthenticated, true);
      expect(updated.user?['name'], 'Alice');
      expect(updated.error, 'Test Error');
      expect(state.isAuthenticated, false); // Original state unmodified
    });
  });
}
