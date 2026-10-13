import 'package:feature_auth/feature_auth.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'dio_provider.dart';

/// Connects each feature's abstract seams to their real implementations.
///
/// A feature's presentation layer may only name `domain` types, so it declares
/// providers like `authRepositoryProvider` that deliberately throw until
/// something supplies the real thing. This is that something — the composition
/// root. It is the only place that knows `AuthRepositoryImpl` exists and which
/// client and store it is built on.
///
/// A function rather than a constant so `main` and the tests assemble the app
/// the same way. [authLocalDataSource] exists for the tests: they cannot use the
/// platform's secure store, so they hand in one that keeps the token in memory
/// and can be inspected. The app itself never passes it.
List<Override> appOverrides({AuthLocalDataSource? authLocalDataSource}) => [
      authRepositoryProvider.overrideWith(
        (ref) => AuthRepositoryImpl(
          AuthRemoteDataSourceImpl(ref.watch(dioProvider)),
          authLocalDataSource ?? const AuthLocalDataSourceImpl(),
        ),
      ),
    ];
