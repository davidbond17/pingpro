import SwiftUI

struct NetworkTheme {
    static let accent = Color(red: 0/255, green: 180/255, blue: 240/255)
    static let accentGreen = Color(red: 76/255, green: 217/255, blue: 100/255)
    static let accentYellow = Color(red: 255/255, green: 214/255, blue: 10/255)
    static let accentOrange = Color(red: 255/255, green: 159/255, blue: 10/255)
    static let accentRed = Color(red: 255/255, green: 69/255, blue: 58/255)

    static let backgroundDeep = Color(red: 10/255, green: 12/255, blue: 16/255)
    static let backgroundElevated = Color(red: 20/255, green: 24/255, blue: 32/255)
    static let backgroundCard = Color(red: 28/255, green: 32/255, blue: 42/255)

    static let textPrimary = Color.white
    static let textSecondary = Color.gray
    static let textTertiary = Color(white: 0.6)

    static let cardCornerRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16

    static func backgroundColor(for scheme: ColorScheme) -> Color {
        scheme == .dark ? backgroundDeep : Color(white: 0.95)
    }

    static func primaryText(for scheme: ColorScheme) -> Color {
        scheme == .dark ? textPrimary : .black
    }

    static func secondaryText(for scheme: ColorScheme) -> Color {
        scheme == .dark ? textSecondary : Color(white: 0.4)
    }
}

extension View {
    func networkTitle() -> some View {
        self
            .font(.system(.title, design: .rounded, weight: .bold))
            .foregroundStyle(NetworkTheme.textPrimary)
    }

    func networkHeadline() -> some View {
        self
            .font(.system(.headline, design: .rounded, weight: .semibold))
            .foregroundStyle(NetworkTheme.textPrimary)
    }

    func networkBody() -> some View {
        self
            .font(.system(.body, design: .default))
            .foregroundStyle(NetworkTheme.textSecondary)
    }

    func networkCaption() -> some View {
        self
            .font(.system(.caption, design: .default))
            .foregroundStyle(NetworkTheme.textTertiary)
    }

    func networkMonospaced() -> some View {
        self
            .font(.system(.body, design: .monospaced, weight: .medium))
            .foregroundStyle(NetworkTheme.textPrimary)
    }
}
