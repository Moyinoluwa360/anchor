import SwiftUI
import WidgetKit

/// exe's palette, matching lib/theme/tokens.dart.
enum Exe {
  static let black = Color(red: 10 / 255, green: 10 / 255, blue: 10 / 255)
  static let surface = Color(red: 20 / 255, green: 20 / 255, blue: 20 / 255)
  static let border = Color(red: 38 / 255, green: 38 / 255, blue: 38 / 255)
  static let grey = Color(red: 138 / 255, green: 138 / 255, blue: 138 / 255)
  static let lemon = Color(red: 212 / 255, green: 1, blue: 58 / 255)

  /// App Group shared with the app (Info.plist → AppGroupId = group.$(APP_BUNDLE_ID)).
  static var groupId: String {
    (Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String) ?? "group.com.exeapp.exe"
  }

  static var defaults: UserDefaults? { UserDefaults(suiteName: groupId) }

  static func string(_ key: String, _ fallback: String = "") -> String {
    defaults?.string(forKey: key) ?? fallback
  }

  static func json<T: Decodable>(_ key: String, as type: T.Type) -> T? {
    guard let s = defaults?.string(forKey: key), let d = s.data(using: .utf8) else { return nil }
    return try? JSONDecoder().decode(T.self, from: d)
  }

  static func mono(_ size: CGFloat, _ weight: Font.Weight = .medium) -> Font {
    .system(size: size, weight: weight, design: .monospaced)
  }

  static func heading(_ size: CGFloat) -> Font {
    .system(size: size, weight: .bold, design: .default)
  }
}

extension View {
  /// iOS 17 wants a container background; iOS 16.2 just gets a plain one.
  @ViewBuilder
  func exeWidgetBackground() -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      self.containerBackground(Exe.black, for: .widget)
    } else {
      self.padding(14).background(Exe.black)
    }
  }
}

/// Every home widget reads the same snapshot; a timeline refreshes it every
/// 15 minutes, and the app reloads it whenever the data changes.
struct ExeEntry: TimelineEntry {
  let date: Date
  let nowTitle: String
  let nowStep: String
  let nowMeta: String
  let top3: [String]
  let targets: [TargetItem]
}

struct TargetItem: Decodable, Hashable {
  let t: String
  let p: Int
}

struct ExeProvider: TimelineProvider {
  func load() -> ExeEntry {
    ExeEntry(
      date: Date(),
      nowTitle: Exe.string("now_title", "Open exe"),
      nowStep: Exe.string("now_step", "One thing at a time."),
      nowMeta: Exe.string("now_meta"),
      top3: Exe.json("top3", as: [String].self) ?? [],
      targets: Exe.json("targets", as: [TargetItem].self) ?? []
    )
  }

  func placeholder(in context: Context) -> ExeEntry {
    ExeEntry(
      date: Date(),
      nowTitle: "Write the onboarding email",
      nowStep: "Open a blank draft",
      nowMeta: "STARTUP · 45m",
      top3: ["Write the onboarding email", "IAM module", "20-minute walk"],
      targets: [TargetItem(t: "Referral loop live", p: 60), TargetItem(t: "Finish IAM + VPC", p: 40)]
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (ExeEntry) -> Void) {
    completion(context.isPreview ? placeholder(in: context) : load())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<ExeEntry>) -> Void) {
    let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
    completion(Timeline(entries: [load()], policy: .after(next)))
  }
}
