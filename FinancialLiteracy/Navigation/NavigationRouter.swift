import SwiftUI

final class NavigationRouter: ObservableObject {
  @Published var path = NavigationPath()

  func popToRoot() {
    path = NavigationPath()
  }
}
