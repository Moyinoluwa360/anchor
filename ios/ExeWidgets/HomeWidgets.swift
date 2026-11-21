import SwiftUI
import WidgetKit

// MARK: - Now card

struct NowWidgetView: View {
  let entry: ExeEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(spacing: 6) {
        Circle().fill(Exe.lemon).frame(width: 7, height: 7)
        Text(entry.nowMeta.isEmpty ? "NOW" : entry.nowMeta)
          .font(Exe.mono(10))
          .foregroundColor(Exe.grey)
          .lineLimit(1)
      }
      Spacer(minLength: 2)
      Text(entry.nowTitle)
        .font(Exe.heading(18))
        .foregroundColor(.white)
        .lineLimit(3)
        .minimumScaleFactor(0.8)
      Text(entry.nowStep)
        .font(.system(size: 12, weight: .medium))
        .foregroundColor(Exe.lemon)
        .lineLimit(2)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    .exeWidgetBackground()
  }
}

struct ExeNowWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "ExeNow", provider: ExeProvider()) { entry in
      NowWidgetView(entry: entry)
    }
    .configurationDisplayName("Now")
    .description("The one thing to do right now, and its first step.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

// MARK: - Today's top 3

struct Top3WidgetView: View {
  let entry: ExeEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("TODAY'S TOP 3")
        .font(Exe.mono(10))
        .foregroundColor(Exe.grey)
      if entry.top3.isEmpty {
        Text("Clear deck.")
          .font(Exe.heading(18))
          .foregroundColor(.white)
      }
      ForEach(Array(entry.top3.prefix(3).enumerated()), id: \.offset) { i, title in
        HStack(alignment: .firstTextBaseline, spacing: 8) {
          Text("\(i + 1)")
            .font(Exe.mono(14, .bold))
            .foregroundColor(Exe.lemon)
          Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .lineLimit(1)
        }
      }
      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .exeWidgetBackground()
  }
}

struct ExeTop3Widget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "ExeTop3", provider: ExeProvider()) { entry in
      Top3WidgetView(entry: entry)
    }
    .configurationDisplayName("Top 3")
    .description("Today's three must-do tasks.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

// MARK: - Weekly targets

struct TargetsWidgetView: View {
  let entry: ExeEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 9) {
      Text("WEEKLY TARGETS")
        .font(Exe.mono(10))
        .foregroundColor(Exe.grey)
      if entry.targets.isEmpty {
        Text("Pick this week's targets in exe.")
          .font(.system(size: 13, weight: .medium))
          .foregroundColor(.white)
      }
      ForEach(entry.targets.prefix(4), id: \.self) { t in
        VStack(alignment: .leading, spacing: 4) {
          HStack {
            Text(t.t)
              .font(.system(size: 12, weight: .semibold))
              .foregroundColor(.white)
              .lineLimit(1)
            Spacer()
            Text("\(t.p)%")
              .font(Exe.mono(12, .bold))
              .foregroundColor(t.p >= 100 ? Exe.lemon : .white)
          }
          GeometryReader { g in
            ZStack(alignment: .leading) {
              Capsule().fill(Exe.border)
              Capsule().fill(Exe.lemon).frame(width: g.size.width * CGFloat(min(max(t.p, 0), 100)) / 100)
            }
          }
          .frame(height: 6)
        }
      }
      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .exeWidgetBackground()
  }
}

struct ExeTargetsWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "ExeTargets", provider: ExeProvider()) { entry in
      TargetsWidgetView(entry: entry)
    }
    .configurationDisplayName("Weekly targets")
    .description("This week's outcomes and how far along they are.")
    .supportedFamilies([.systemMedium, .systemLarge])
  }
}
