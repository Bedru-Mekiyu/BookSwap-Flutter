import 'package:flutter_test/flutter_test.dart';
import 'package:bookswap/providers/auth_provider.dart';

void main() {
  group('User Management Unit Tests', () {
    test('ProfileState initial values', () {
      const state = ProfileState();
      expect(state.username, 'Loading...');
      expect(state.email, 'Loading...');
      expect(state.profilePic, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('ProfileState copyWith updates fields properly', () {
      const state = ProfileState();
      final updated = state.copyWith(
        username: 'Bob',
        email: 'bob@bookswap.com',
        profilePic: 'uploads/bob.jpg',
      );

      expect(updated.username, 'Bob');
      expect(updated.email, 'bob@bookswap.com');
      expect(updated.profilePic, 'uploads/bob.jpg');
    });
  });
}
