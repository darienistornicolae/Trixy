import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    // For development purposes, we'll use a static userId
    let currentUserId = "dev_user_123"
    
    private init() {}
} 