import SwiftUI

@main
struct KopipesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No windows — this is a menu bar only app
        Settings {
            EmptyView()
        }
    }
}
