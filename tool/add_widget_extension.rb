#!/usr/bin/env ruby
# Adds the AnchorWidgets extension (home screen widgets + lock-screen timer
# Live Activity) to ios/Runner.xcodeproj without Xcode. Runs on Codemagic
# only when ENABLE_WIDGETS=true. Safe to run twice.
#
#   gem install xcodeproj && ruby tool/add_widget_extension.rb
require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
IOS = File.join(ROOT, 'ios')
NAME = 'AnchorWidgets'

bundle_id = File.read(File.join(IOS, 'Flutter', 'AppConfig.xcconfig'))[/^APP_BUNDLE_ID\s*=\s*(\S+)/, 1]
abort 'APP_BUNDLE_ID not found in ios/Flutter/AppConfig.xcconfig' unless bundle_id

project = Xcodeproj::Project.open(File.join(IOS, 'Runner.xcodeproj'))
if project.targets.any? { |t| t.name == NAME }
  puts "#{NAME} is already in the project."
  exit 0
end

app = project.targets.find { |t| t.name == 'Runner' } or abort 'Runner target not found'

# 1. The extension target.
ext = project.new_target(:app_extension, NAME, :ios, '16.2', project.products_group, :swift)

# 2. Its source files, Info.plist and entitlements (ios/AnchorWidgets/*).
group = project.main_group.new_group(NAME, NAME)
swift = Dir[File.join(IOS, NAME, '*.swift')].sort
abort "No Swift files in ios/#{NAME}" if swift.empty?
refs = swift.map { |f| group.new_reference(File.basename(f)) }
ext.add_file_references(refs)
group.new_reference('Info.plist')
group.new_reference("#{NAME}.entitlements")

# 3. Build settings. Base config gives FLUTTER_BUILD_NAME/NUMBER and APP_BUNDLE_ID.
flutter_group = project.main_group.children.find { |g| g.display_name == 'Flutter' } or abort 'Flutter group not found'
xcconfig = flutter_group.files.find { |f| f.path == 'Extension.xcconfig' } || flutter_group.new_reference('Extension.xcconfig')
ext.build_configurations.each do |config|
  config.base_configuration_reference = xcconfig
  s = config.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = '$(APP_BUNDLE_ID).widgets'
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['INFOPLIST_FILE'] = "#{NAME}/Info.plist"
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
  s['CODE_SIGN_ENTITLEMENTS'] = "#{NAME}/#{NAME}.entitlements"
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '16.2'
  s['TARGETED_DEVICE_FAMILY'] = '1'
  s['SWIFT_VERSION'] = '5.0'
  s['MARKETING_VERSION'] = '$(FLUTTER_BUILD_NAME)'
  s['CURRENT_PROJECT_VERSION'] = '$(FLUTTER_BUILD_NUMBER)'
  s['SKIP_INSTALL'] = 'YES'
  s['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
end

# 4. No explicit framework references: Swift autolinks Foundation, WidgetKit,
#    SwiftUI and ActivityKit from its imports, and explicit references would
#    pin an SDK version (iPhoneOSxx.x.sdk) that breaks on other Xcode versions.
ext.frameworks_build_phase.files.to_a.each(&:remove_from_project)

# 5. Embed the extension in the app, before Flutter's "Thin Binary" script
#    (otherwise Xcode reports a build cycle).
app.add_dependency(ext)
embed = app.new_copy_files_build_phase('Embed Foundation Extensions')
embed.dst_subfolder_spec = '13' # PlugIns
build_file = embed.add_file_reference(ext.product_reference, true)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
thin = app.build_phases.find { |p| p.respond_to?(:name) && p.name == 'Thin Binary' }
if thin
  app.build_phases.delete(embed)
  app.build_phases.insert(app.build_phases.index(thin), embed)
end

# 6. The app joins the same App Group so both can read the widget data.
ent_path = File.join(IOS, 'Runner', 'Runner.entitlements')
ent = File.exist?(ent_path) ? Xcodeproj::Plist.read_from_path(ent_path) : {}
ent['com.apple.security.application-groups'] = ["group.#{bundle_id}"]
Xcodeproj::Plist.write_to_path(ent, ent_path)

project.save
puts "Added #{NAME} (#{bundle_id}.widgets) with App Group group.#{bundle_id}."
