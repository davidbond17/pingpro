import SwiftUI

struct TroubleshootStep: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let category: TroubleshootCategory
}

enum TroubleshootCategory {
    case latency
    case packetLoss
    case general
}

struct TroubleshootingView: View {
    let avgLatency: Double?
    let packetLoss: Double
    let networkType: NetworkType

    @State private var completedSteps: Set<UUID> = []
    @State private var isExpanded = false

    private var relevantSteps: [TroubleshootStep] {
        var steps: [TroubleshootStep] = []

        if let latency = avgLatency, latency > 100 {
            steps.append(contentsOf: latencySteps)
        }

        if packetLoss > 3 {
            steps.append(contentsOf: packetLossSteps)
        }

        if steps.isEmpty {
            steps.append(contentsOf: generalSteps)
        }

        return steps
    }

    private var latencySteps: [TroubleshootStep] {
        var steps = [
            TroubleshootStep(
                icon: "arrow.clockwise",
                title: "Restart Your Router",
                description: "Power off your router for 30 seconds, then turn it back on",
                category: .latency
            ),
            TroubleshootStep(
                icon: "location.fill",
                title: "Move Closer to Router",
                description: "Physical distance and walls reduce signal strength",
                category: .latency
            ),
            TroubleshootStep(
                icon: "wifi.exclamationmark",
                title: "Switch to 5GHz Band",
                description: "5GHz is faster but shorter range than 2.4GHz",
                category: .latency
            ),
            TroubleshootStep(
                icon: "xmark.circle",
                title: "Close Background Apps",
                description: "Other apps may be using bandwidth and increasing latency",
                category: .latency
            ),
            TroubleshootStep(
                icon: "person.3.fill",
                title: "Check for Network Congestion",
                description: "Too many devices on the same network can slow everyone down",
                category: .latency
            )
        ]

        if networkType == .cellular {
            steps.insert(TroubleshootStep(
                icon: "wifi",
                title: "Switch to WiFi",
                description: "WiFi typically has lower latency than cellular",
                category: .latency
            ), at: 0)
        }

        return steps
    }

    private var packetLossSteps: [TroubleshootStep] {
        [
            TroubleshootStep(
                icon: "antenna.radiowaves.left.and.right",
                title: "Check for Interference",
                description: "Microwaves, Bluetooth devices, and other WiFi networks can cause interference",
                category: .packetLoss
            ),
            TroubleshootStep(
                icon: "arrow.clockwise",
                title: "Restart Your Router",
                description: "A fresh start can resolve temporary packet loss issues",
                category: .packetLoss
            ),
            TroubleshootStep(
                icon: "cable.connector",
                title: "Try a Wired Connection",
                description: "Ethernet eliminates wireless interference entirely",
                category: .packetLoss
            ),
            TroubleshootStep(
                icon: "arrow.up.circle",
                title: "Update Router Firmware",
                description: "Outdated firmware can cause stability issues",
                category: .packetLoss
            ),
            TroubleshootStep(
                icon: "phone.fill",
                title: "Contact Your ISP",
                description: "Persistent packet loss may indicate a problem on your provider's end",
                category: .packetLoss
            )
        ]
    }

    private var generalSteps: [TroubleshootStep] {
        [
            TroubleshootStep(
                icon: "checkmark.seal.fill",
                title: "Connection Looks Good",
                description: "No troubleshooting needed right now",
                category: .general
            ),
            TroubleshootStep(
                icon: "lightbulb.fill",
                title: "Tip: Test at Different Times",
                description: "Network performance varies throughout the day",
                category: .general
            ),
            TroubleshootStep(
                icon: "chart.line.uptrend.xyaxis",
                title: "Tip: Monitor Regularly",
                description: "Track your connection over time to spot patterns",
                category: .general
            )
        ]
    }

    private var showTroubleshootButton: Bool {
        if let latency = avgLatency, latency > 100 { return true }
        if packetLoss > 3 { return true }
        return false
    }

    var body: some View {
        if showTroubleshootButton || isExpanded {
            GlassCard {
                VStack(alignment: .leading, spacing: 16) {
                    Button(action: {
                        withAnimation(.spring(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "wrench.and.screwdriver.fill")
                                .foregroundStyle(NetworkTheme.accentOrange)

                            Text("Troubleshoot")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(NetworkTheme.textPrimary)

                            Spacer()

                            if !isExpanded {
                                Text("Tap to fix")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(NetworkTheme.accentOrange)
                            }

                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(NetworkTheme.textSecondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    if isExpanded {
                        issueHeader

                        ForEach(relevantSteps) { step in
                            stepRow(step: step)
                        }

                        if !completedSteps.isEmpty {
                            retestPrompt
                        }
                    }
                }
            }
        }
    }

    private var issueHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let latency = avgLatency, latency > 100 {
                HStack(spacing: 6) {
                    Circle()
                        .fill(NetworkTheme.accentOrange)
                        .frame(width: 8, height: 8)
                    Text("High latency detected (\(Int(latency))ms)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(NetworkTheme.accentOrange)
                }
            }

            if packetLoss > 3 {
                HStack(spacing: 6) {
                    Circle()
                        .fill(NetworkTheme.accentRed)
                        .frame(width: 8, height: 8)
                    Text("Packet loss detected (\(String(format: "%.1f", packetLoss))%)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(NetworkTheme.accentRed)
                }
            }
        }
    }

    private func stepRow(step: TroubleshootStep) -> some View {
        let isCompleted = completedSteps.contains(step.id)

        return Button(action: {
            withAnimation(.spring(duration: 0.2)) {
                if isCompleted {
                    completedSteps.remove(step.id)
                } else {
                    completedSteps.insert(step.id)
                }
            }
        }) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : step.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isCompleted ? NetworkTheme.accentGreen : NetworkTheme.accent)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 3) {
                    Text(step.title)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(isCompleted ? NetworkTheme.textTertiary : NetworkTheme.textPrimary)
                        .strikethrough(isCompleted)

                    Text(step.description)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(NetworkTheme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(.vertical, 6)
            .opacity(isCompleted ? 0.6 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var retestPrompt: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundStyle(NetworkTheme.accent)

            Text("Try these steps, then restart monitoring to test again")
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(NetworkTheme.textSecondary)
        }
        .padding(.top, 4)
    }
}
