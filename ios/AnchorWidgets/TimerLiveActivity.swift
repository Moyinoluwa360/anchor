import ActivityKit
import SwiftUI
import WidgetKit

/// Required by the live_activities plugin: the name must be EXACTLY this.
/// Values arrive through the shared App Group, keyed with prefixedKey(_:).
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
  public typealias LiveDeliveryData = ContentState
  public struct ContentState: Codable, Hashable {}
  var id = UUID()
}

extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String { "\(id)_\(key)" }
}

/// What the Dart side sends (lib/services/widget_sync.dart → LiveActivityTimer.payload).
struct TimerData {
  let title: String
  let phase: String
  let minutes: Int
  let start: Date
  let end: Date
  let paused: Bool
  let remaining: Int

  init(_ attrs: LiveActivitiesAppAttributes) {
    let d = Anchor.defaults
    title = d?.string(forKey: attrs.prefixedKey("title")) ?? "Focus"
    phase = d?.string(forKey: attrs.prefixedKey("phase")) ?? "FOCUS"
    minutes = d?.integer(forKey: attrs.prefixedKey("minutes")) ?? 25
    let s = d?.double(forKey: attrs.prefixedKey("startEpoch")) ?? Date().timeIntervalSince1970
    let e = d?.double(forKey: attrs.prefixedKey("endEpoch")) ?? (s + 1500)
    start = Date(timeIntervalSince1970: s)
    end = Date(timeIntervalSince1970: max(e, s + 1))
    paused = d?.bool(forKey: attrs.prefixedKey("paused")) ?? false
    remaining = d?.integer(forKey: attrs.prefixedKey("remaining")) ?? 0
  }

  var isBreak: Bool { phase == "BREAK" }
  var accent: Color { isBreak ? .white : Anchor.lemon }
  var pausedText: String { String(format: "%02d:%02d", remaining / 60, remaining % 60) }
}

/// Lock screen and banner. The phone has no Dynamic Island, so that layout
/// is minimal but valid.
struct TimerLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
      LockScreenTimer(data: TimerData(context.attributes))
        .activityBackgroundTint(Anchor.black)
        .activitySystemActionForegroundColor(Anchor.lemon)
    } dynamicIsland: { context in
      let data = TimerData(context.attributes)
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Text(data.phase).font(Anchor.mono(12, .bold)).foregroundColor(data.accent)
        }
        DynamicIslandExpandedRegion(.trailing) {
          countdown(data, size: 22)
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text(data.title).font(.system(size: 14, weight: .semibold)).lineLimit(1)
        }
      } compactLeading: {
        Image(systemName: data.isBreak ? "cup.and.saucer.fill" : "bolt.fill").foregroundColor(data.accent)
      } compactTrailing: {
        countdown(data, size: 13).frame(maxWidth: 52)
      } minimal: {
        Image(systemName: "timer").foregroundColor(data.accent)
      }
    }
  }
}

@ViewBuilder
private func countdown(_ data: TimerData, size: CGFloat) -> some View {
  if data.paused {
    Text(data.pausedText).font(Anchor.mono(size, .bold)).foregroundColor(.white)
  } else {
    Text(timerInterval: data.start...data.end, countsDown: true)
      .font(Anchor.mono(size, .bold))
      .monospacedDigit()
      .foregroundColor(.white)
      .multilineTextAlignment(.trailing)
  }
}

struct LockScreenTimer: View {
  let data: TimerData

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .center, spacing: 12) {
        VStack(alignment: .leading, spacing: 4) {
          Text("\(data.phase) · \(data.minutes) MIN\(data.paused ? " · PAUSED" : "")")
            .font(Anchor.mono(11, .medium))
            .foregroundColor(data.accent)
          Text(data.isBreak ? "Step away. Breathe." : data.title)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .lineLimit(2)
        }
        Spacer(minLength: 8)
        countdown(data, size: 34)
          .frame(maxWidth: 140, alignment: .trailing)
      }
      if data.paused {
        Capsule().fill(Anchor.border).frame(height: 6)
      } else {
        ProgressView(timerInterval: data.start...data.end, countsDown: true) {
          EmptyView()
        } currentValueLabel: {
          EmptyView()
        }
        .progressViewStyle(.linear)
        .tint(data.accent)
      }
    }
    .padding(16)
  }
}
