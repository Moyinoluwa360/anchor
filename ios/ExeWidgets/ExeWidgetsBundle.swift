import SwiftUI
import WidgetKit

@main
struct ExeWidgetsBundle: WidgetBundle {
  var body: some Widget {
    ExeNowWidget()
    ExeTop3Widget()
    ExeTargetsWidget()
    TimerLiveActivity()
  }
}
