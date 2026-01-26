import SwiftUI

struct StatsCardView: View {
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(NetworkTheme.textSecondary)
                    .textCase(.uppercase)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundStyle(color)

                    Text(unit)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(NetworkTheme.textTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
