import 'package:feature_auth/feature_auth.dart';
import 'package:feature_listings/feature_listings.dart';
import 'package:go_router/go_router.dart';

/// Every route path in the app, in one place.
///
/// These strings are real URLs on web, so they are part of the app's public
/// surface — renaming one breaks any link someone saved.
///
/// They live in the app shell, not in the features, on purpose: a feature that
/// knew another feature's path would depend on it. Only this file knows that
/// signing in leads to the listings.
abstract final class AppRoutes {
  /// The app opens here.
  static const login = '/';

  /// The listings feed, shown once someone is signed in.
  static const listings = '/listings';
}

/// Builds the app's route table.
///
/// A factory rather than only a shared value so tests can get a router with a
/// fresh location; a single global one would carry navigation from one test
/// into the next.
GoRouter createAppRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => LoginView(
          // `go` rather than `push`: after signing in, the back button must not
          // return to the login form.
          onLoggedIn: () => context.go(AppRoutes.listings),
        ),
      ),
      GoRoute(
        path: AppRoutes.listings,
        name: 'listings',
        builder: (context, state) => const ListingsView(),
      ),
    ],
  );
}

/// The router the running app uses.
///
/// Becomes a provider once something needs to redirect on authentication state,
/// since the redirect has to read it.
final appRouter = createAppRouter();
