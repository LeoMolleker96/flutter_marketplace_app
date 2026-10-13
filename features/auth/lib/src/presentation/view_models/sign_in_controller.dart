import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/params/sign_in_params.dart';
import '../providers/sign_in_use_case_provider.dart';

part 'sign_in_controller.g.dart';

/// Tracks one sign-in attempt: idle, in flight, succeeded, or failed.
///
/// An `AsyncNotifier<void>` because it models an **action**, not data. There is
/// nothing to load when it is created, so `build` is empty and the value is
/// `void`; what matters is the `AsyncValue` around it, which already is the
/// loading / data / error union a view needs. Coming from Bloc, think of it as
/// the Cubit whose state is the progress of a single call.
///
/// Auto-disposed on purpose: it belongs to the sign-in screen and should reset
/// when the screen goes away. Who is signed in *right now* is a different
/// question, owned by the session, not by this controller.
@riverpod
class SignInController extends _$SignInController {
  @override
  FutureOr<void> build() {}

  /// Attempts to sign in with [params].
  ///
  /// Moves the state to loading, then to data on success or to error with the
  /// thrown failure. The error is held in the state rather than rethrown, so the
  /// view reads it with `ref.listen` instead of wrapping a call in try/catch.
  Future<void> signIn(SignInParams params) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ref.read(signInUseCaseProvider)(params),
    );

    // The screen may have gone away while the request was in flight, and a
    // disposed notifier must not be written to.
    if (!ref.mounted) return;

    state = result;
  }
}
