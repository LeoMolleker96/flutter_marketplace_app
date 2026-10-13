/// HTTP connectivity for the app, built on dio.
///
/// This is the package's only public entry point; everything else belongs under
/// `src/`.
///
/// dio's own types are re-exported so that the rest of the workspace depends on
/// `network` and never on dio directly. A data layer that needs to build a
/// request or catch a `DioException` imports it from here, and which HTTP
/// library sits underneath stays this package's business.
library;

export 'package:dio/dio.dart';

export 'src/create_dio.dart';
