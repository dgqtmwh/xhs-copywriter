import SwiftUI

@main
struct XHSCopywriterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, Locale(identifier: "zh_CN"))
        }
    }
}
