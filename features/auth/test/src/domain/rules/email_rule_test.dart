import 'package:feature_auth/src/domain/rules/email_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isValid', () {
    for (final email in [
      'ana@example.com',
      'ana.perez+tag@sub.example.co',
      'a@b.c',
    ]) {
      test('accepts "$email"', () {
        expect(EmailRule.isValid(email), isTrue);
      });
    }

    for (final email in [
      '',
      '   ',
      'ana',
      'ana@',
      '@example.com',
      'ana@example',
      'ana@@example.com',
      'ana perez@example.com',
      'ana@exam ple.com',
    ]) {
      test('rejects "$email"', () {
        expect(EmailRule.isValid(email), isFalse);
      });
    }

    test('ignores spaces around the address', () {
      // The screens trim before sending, so the rule judges what will be sent.
      expect(EmailRule.isValid('  ana@example.com  '), isTrue);
      expect(EmailRule.isValid('\tana@example.com\n'), isTrue);
    });
  });
}
