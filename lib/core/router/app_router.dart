import 'package:go_router/go_router.dart';
import 'package:marketplace_app/features/auth/presentation/views/login_view.dart';
import 'package:marketplace_app/features/listings/presentation/views/listings_view.dart';

/// Every route path in the app, in one place.
///
/// These strings are real URLs on web, so they are part of the app's public
/// surface — renaming one breaks any link someone saved.
abstract final class AppRoutes {
  /// The app opens here.
  static const login = '/';

  /// The listings feed, shown once someone is signed in.
  static const listings = '/listings';
}

/// The app's router.
///
/// A plain top-level value for now. It becomes a provider once something needs
/// to redirect on authentication state, since the redirect has to read it.
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: AppRoutes.listings,
      name: 'listings',
      builder: (context, state) => const ListingsView(),
    ),
  ],
);
