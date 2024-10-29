import SwiftUI

@main
struct FinancialLiteracyApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  var body: some Scene {
    WindowGroup {
      MainTabView()
    }
  }
}
