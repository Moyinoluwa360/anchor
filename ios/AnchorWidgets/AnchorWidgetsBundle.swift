import SwiftUI
import WidgetKit

@main
struct AnchorWidgetsBundle: WidgetBundle {
  var body: some Widget {
    AnchorNowWidget()
    AnchorTop3Widget()
    AnchorTargetsWidget()
    TimerLiveActivity()
  }
}
