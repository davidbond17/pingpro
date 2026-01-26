import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(NetworkTheme.cardPadding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: NetworkTheme.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: NetworkTheme.cardCornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}
