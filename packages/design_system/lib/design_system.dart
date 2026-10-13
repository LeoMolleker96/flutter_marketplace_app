/// The design system: colours, type scale, spacing tokens and the shared
/// widgets every feature builds its screens from.
///
/// This is the package's only public entry point. Everything under `src/` is
/// private to it, so a feature can depend on what is exported here and nothing
/// else — which keeps the design system free to reorganise its internals.
library;

export 'src/layout/window_size_class.dart';
export 'src/theme/app_colors.dart';
export 'src/theme/app_spacing.dart';
export 'src/theme/app_theme.dart';
export 'src/theme/app_typography.dart';
export 'src/theme/theme_context_extension.dart';
export 'src/widgets/app_checkbox.dart';
export 'src/widgets/app_primary_button.dart';
export 'src/widgets/app_text.dart';
export 'src/widgets/app_text_field.dart';
