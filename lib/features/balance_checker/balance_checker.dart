/// Balance Checker feature module.
///
/// Provides gift card balance checking via hidden WebView
/// with JavaScript injection for Phase 1 retailers, and
/// redirect fallback for Phase 2 retailers.
library;

// Domain
export 'domain/entities/balance_result.dart';
export 'domain/entities/retailer_config.dart';

// Data
export 'data/models/retailer_config_model.dart';
export 'data/retailer_configs.dart';

// Presentation - Services
export 'presentation/services/balance_checker_service.dart';
export 'presentation/services/javascript_bridge.dart';
export 'presentation/services/webview_manager.dart';

// Presentation - Screens
export 'presentation/screens/balance_check_screen.dart';
export 'presentation/screens/scan_card_screen.dart';

// Presentation - Widgets
export 'presentation/widgets/balance_loading_widget.dart';
export 'presentation/widgets/captcha_overlay_widget.dart';
export 'presentation/widgets/manual_balance_entry.dart';

// Presentation - Providers
export 'presentation/providers/balance_checker_providers.dart';
