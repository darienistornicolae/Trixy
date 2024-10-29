import Foundation
import SwiftUI

struct ResourceSection: Identifiable, Codable, Hashable {
  let id: String
  let title: String
  let content: String

  init(id: String = UUID().uuidString, title: String, content: String) {
    self.id = id
    self.title = title
    self.content = content
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: ResourceSection, rhs: ResourceSection) -> Bool {
    lhs.id == rhs.id
  }
}

struct ResourceTopic: Identifiable, Codable, Hashable {
  let id: String
  let title: String
  let description: String
  let iconName: String
  let content: [ResourceSection]

  init(id: String = UUID().uuidString,
       title: String,
       description: String,
       iconName: String,
       content: [ResourceSection]) {
    self.id = id
    self.title = title
    self.description = description
    self.iconName = iconName
    self.content = content
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: ResourceTopic, rhs: ResourceTopic) -> Bool {
    lhs.id == rhs.id
  }
}
