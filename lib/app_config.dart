/// Identifiers shared with native iOS code. Must match
/// ios/Flutter/AppConfig.xcconfig and BUNDLE_ID in codemagic.yaml
/// (tool/check_bundle_id.sh checks this on every Codemagic build).
abstract final class AppConfig {
  static const bundleId = 'com.anchorapp.anchor';
  static const appGroup = 'group.$bundleId';
  static const widgetKind = 'AnchorWidgets';
}
