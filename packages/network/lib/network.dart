/// HTTP connectivity for the app, built on dio.
///
/// This is the package's only public entry point; everything else belongs under
/// `src/`.
///
/// dio's own types are re-exported so that the rest of the workspace depends on
/// `network` and never on dio directly. A data layer that needs to build a
/// request or catch a `DioException` imports it from here. That makes dio's
/// types (`Dio`, `DioException`, `DioExceptionType`) part of this package's
/// effective public API: feature data layers use them, so swapping the HTTP
/// library would touch every feature's data layer, not only this package. The
/// single shared client is a convention, not something the package enforces
/// (ADR-0004).
library;

export 'package:dio/dio.dart';

export 'src/create_dio.dart';
