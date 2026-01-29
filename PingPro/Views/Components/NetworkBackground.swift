import SwiftUI

struct NetworkBackground: View {
    var body: some View {
        ZStack {
            NetworkTheme.backgroundDeep
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    NetworkTheme.accent.opacity(0.15),
                    Color.clear,
                    NetworkTheme.accent.opacity(0.08),
                    Color.clear,
                    NetworkTheme.backgroundDeep
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    NetworkTheme.accent.opacity(0.12),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()
        }
    }
}

extension View {
    func networkBackground() -> some View {
        self.background(NetworkBackground())
    }
}
