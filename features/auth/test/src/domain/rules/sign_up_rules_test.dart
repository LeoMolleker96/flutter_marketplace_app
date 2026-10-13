import 'package:feature_auth/src/domain/rules/sign_up_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isValidEmail', () {
    for (final email in [
      'ana@example.com',
      'ana.perez+tag@sub.example.co',
      '  ana@example.com  ',
    ]) {
      test('accepts "$email"', () {
        expect(SignUpRules.isValidEmail(email), isTrue);
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
        expect(SignUpRules.isValidEmail(email), isFalse);
      });
    }
  });

  group('PasswordRequirement', () {
    group('minLength', () {
      test('is not met one character short', () {
        expect(PasswordRequirement.minLength.isMetBy('a' * 7), isFalse);
      });

      test('is met at exactly the minimum', () {
        expect(
          PasswordRequirement.minLength.isMetBy(
            'a' * SignUpRules.minPasswordLength,
          ),
          isTrue,
        );
      });

      test('is met above the minimum', () {
        expect(PasswordRequirement.minLength.isMetBy('a' * 40), isTrue);
      });

      test('counts spaces, because a password is never trimmed', () {
        expect(PasswordRequirement.minLength.isMetBy('        '), isTrue);
      });

      test('is not met by an empty password', () {
        expect(PasswordRequirement.minLength.isMetBy(''), isFalse);
      });
    });

    group('uppercase', () {
      for (final password in ['A', 'abcA', 'Zebra', 'ñandÚ', 'Ωmega']) {
        test('is met by "$password"', () {
          expect(PasswordRequirement.uppercase.isMetBy(password), isTrue);
        });
      }

      for (final password in ['', 'abc', '123', '!!!', 'ñandú']) {
        test('is not met by "$password"', () {
          expect(PasswordRequirement.uppercase.isMetBy(password), isFalse);
        });
      }
    });

    group('number', () {
      for (final password in ['1', 'abc9', 'a1b', '٣']) {
        test('is met by "$password"', () {
          expect(PasswordRequirement.number.isMetBy(password), isTrue);
        });
      }

      for (final password in ['', 'abc', 'ABC', '!!!', 'one two']) {
        test('is not met by "$password"', () {
          expect(PasswordRequirement.number.isMetBy(password), isFalse);
        });
      }
    });

    group('symbol', () {
      for (final password in [
        '!',
        'a#',
        r'a$',
        'a_b',
        'a-b',
        '¿',
        '€',
        'a.b',
      ]) {
        test('is met by "$password"', () {
          expect(PasswordRequirement.symbol.isMetBy(password), isTrue);
        });
      }

      for (final password in [
        '',
        'abc',
        'ABC',
        '123',
        'Ñandú9',
        ' ',
        'a b',
        '\t',
      ]) {
        test('is not met by "${password.replaceAll('\t', r'\t')}"', () {
          expect(PasswordRequirement.symbol.isMetBy(password), isFalse);
        });
      }
    });

    test('lists exactly the four requirements, in display order', () {
      expect(PasswordRequirement.values, [
        PasswordRequirement.minLength,
        PasswordRequirement.uppercase,
        PasswordRequirement.number,
        PasswordRequirement.symbol,
      ]);
    });
  });

  group('unmetRequirements', () {
    test('is all four for an empty password', () {
      expect(SignUpRules.unmetRequirements(''), PasswordRequirement.values);
    });

    test('names only what is missing, in display order', () {
      expect(SignUpRules.unmetRequirements('abcdefgh'), [
        PasswordRequirement.uppercase,
        PasswordRequirement.number,
        PasswordRequirement.symbol,
      ]);
    });

    test('is empty for a password that meets them all', () {
      expect(SignUpRules.unmetRequirements('Hunter22!'), isEmpty);
    });
  });

  group('isValidPassword', () {
    for (final password in [
      'Hunter22!',
      'Abcdef1#',
      'Ñandú_2025',
      'A1!aaaaa',
    ]) {
      test('accepts "$password"', () {
        expect(SignUpRules.isValidPassword(password), isTrue);
      });
    }

    for (final entry in {
      'too short': 'Aa1!',
      'no uppercase letter': 'hunter22!',
      'no number': 'Hunterxx!',
      'no symbol': 'Hunter22x',
      'only a long run of lowercase': 'abcdefghijkl',
      'empty': '',
    }.entries) {
      test('rejects a password with ${entry.key}', () {
        expect(SignUpRules.isValidPassword(entry.value), isFalse);
      });
    }
  });

  group('passwordsMatch', () {
    test('accepts identical text', () {
      expect(SignUpRules.passwordsMatch('Hunter22!', 'Hunter22!'), isTrue);
    });

    test('is case sensitive', () {
      expect(SignUpRules.passwordsMatch('Hunter22!', 'hunter22!'), isFalse);
    });

    test('does not ignore a trailing space', () {
      expect(SignUpRules.passwordsMatch('Hunter22!', 'Hunter22! '), isFalse);
    });
  });

  group('isComplete', () {
    bool complete({
      String email = 'ana@example.com',
      String password = 'Hunter22!',
      String confirmation = 'Hunter22!',
    }) => SignUpRules.isComplete(
      email: email,
      password: password,
      confirmation: confirmation,
    );

    test('is true when every rule holds', () {
      expect(complete(), isTrue);
    });

    test('is false with an invalid email', () {
      expect(complete(email: 'ana'), isFalse);
    });

    test('is false with a short password, even if it is repeated', () {
      expect(complete(password: 'Aa1!', confirmation: 'Aa1!'), isFalse);
    });

    test(
      'is false with a password missing a requirement, even if repeated',
      () {
        expect(
          complete(password: 'hunter22!', confirmation: 'hunter22!'),
          isFalse,
        );
      },
    );

    test('is false when the confirmation differs', () {
      expect(complete(confirmation: 'Hunter23!'), isFalse);
    });

    test('is false when the confirmation is empty', () {
      expect(complete(confirmation: ''), isFalse);
    });
  });
}
