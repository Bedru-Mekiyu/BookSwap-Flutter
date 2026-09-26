import 'package:flutter_test/flutter_test.dart';
import 'package:bookswap/providers/auth_provider.dart';

void main() {
  group('Authorization Unit Tests', () {
    test('admin role detection from auth state', () {
      final state = const AuthState().copyWith(
        isAuthenticated: true,
        user: {'role': 'admin', 'name': 'SuperAdmin'},
      );

      final isAdmin = state.user?['role'] == 'admin';
      expect(isAdmin, true);
    });

    test('standard user cannot pass admin check', () {
      final state = const AuthState().copyWith(
        isAuthenticated: true,
        user: {'role': 'user', 'name': 'RegularUser'},
      );

      final isAdmin = state.user?['role'] == 'admin';
      expect(isAdmin, false);
    });
  });
}
