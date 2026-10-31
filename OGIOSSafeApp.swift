import SwiftUI

@main
struct OGIOSSafeApp: App {
    var body: some Scene {
        WindowGroup {
            SafeHomeView()
                .preferredColorScheme(.dark)
        }
    }
}
