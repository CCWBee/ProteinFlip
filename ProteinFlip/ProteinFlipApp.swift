import SwiftUI

@main
struct ProteinFlipApp: App {
    @StateObject private var store = ProteinStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
                .onAppear { store.handleRolloverIfNeeded() }
        }
    }
}

