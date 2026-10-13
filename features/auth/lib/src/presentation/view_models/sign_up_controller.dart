import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/params/sign_up_params.dart';
import '../providers/sign_up_use_case_provider.dart';

part 'sign_up_controller.g.dart';

/// Tracks one sign-up attempt: idle, in flight, succeeded, or failed.
///
/// The twin of `SignInController`, an `AsyncNotifier<void>` for the same
/// reason: it models an **action**, so `build` is empty and the `AsyncValue`
/// around the `void` is the whole state. Two controllers rather than one because
/// the two screens are open at different times and must not show each other's
/// progress or errors.
///
/// Auto-disposed: it belongs to the sign-up screen and resets when the screen
/// goes away.
@riverpod
class SignUpController extends _$SignUpController {
  @override
  FutureOr<void> build() {}

  /// Attempts to create an account with [params].
  ///
  /// Moves the state to loading, then to data on success or to error with the
  /// thrown failure, which the view reads with `ref.listen` instead of a
  /// try/catch.
  Future<void> signUp(SignUpParams params) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ref.read(signUpUseCaseProvider)(params),
    );

    // The screen may have gone away while the request was in flight, and a
    // disposed notifier must not be written to.
    if (!ref.mounted) return;

    state = result;
  }
}
