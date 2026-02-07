import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [PingSession]

    @AppStorage(UserDefaults.Keys.targetHost) private var targetHost = "8.8.8.8"
    @AppStorage(UserDefaults.Keys.pingInterval) private var pingInterval = 1.0
    @AppStorage(UserDefaults.Keys.dataRetentionDays) private var dataRetentionDays = 30
    @AppStorage(UserDefaults.Keys.alertsEnabled) private var alertsEnabled = false
    @AppStorage(UserDefaults.Keys.latencyThreshold) private var latencyThreshold = 150.0
    @AppStorage(UserDefaults.Keys.packetLossThreshold) private var packetLossThreshold = 5.0
    @AppStorage(UserDefaults.Keys.alertOnNetworkChange) private var alertOnNetworkChange = true

    @State private var showInvalidHostAlert = false
    @State private var showClearHistoryAlert = false
    @State private var tempHost: String = ""
    @State private var showPermissionAlert = false

    var body: some View {
        ZStack {
            NetworkBackground()

            ScrollView {
                VStack(spacing: 24) {
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)

                    VStack(spacing: 16) {
                        pingConfigSection
                        alertsSection
                        dataManagementSection
                        aboutSection
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            tempHost = targetHost
        }
        .alert("Invalid Host", isPresented: $showInvalidHostAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter a valid hostname or IP address.")
        }
        .alert("Clear History", isPresented: $showClearHistoryAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                clearHistory()
            }
        } message: {
            Text("Are you sure you want to delete all session history?")
        }
        .alert("Notification Permission Required", isPresented: $showPermissionAlert) {
            Button("OK", role: .cancel) {}
            Button("Open Settings", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please enable notifications in Settings to receive connection alerts.")
        }
    }

    private var pingConfigSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 20) {
                sectionHeader(title: "Ping Configuration")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Host")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(NetworkTheme.textSecondary)

                    HStack {
                        TextField("8.8.8.8", text: $tempHost)
                            .font(.system(size: 16, design: .monospaced))
                            .textFieldStyle(.plain)
                            .foregroundStyle(NetworkTheme.textPrimary)
                            .padding(12)
                            .background(NetworkTheme.backgroundCard)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onSubmit {
                                updateHost()
                            }

                        Button(action: updateHost) {
                            Text("Save")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(NetworkTheme.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    Text("Examples: 8.8.8.8, google.com, 1.1.1.1")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(NetworkTheme.textTertiary)
                }

                Divider()
                    .background(NetworkTheme.textTertiary.opacity(0.2))

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Ping Interval")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(NetworkTheme.textSecondary)

                        Spacer()

                        Text(String(format: "%.1f s", pingInterval))
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundStyle(NetworkTheme.textPrimary)
                    }

                    Slider(value: $pingInterval, in: 0.5...5.0, step: 0.5)
                        .tint(NetworkTheme.accent)
                }
            }
        }
    }

    private var alertsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 20) {
                sectionHeader(title: "Alerts & Notifications")

                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: $alertsEnabled) {
                        Text("Enable Alerts")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(NetworkTheme.textSecondary)
                    }
                    .tint(NetworkTheme.accent)
                    .onChange(of: alertsEnabled) { oldValue, newValue in
                        if newValue {
                            requestNotificationPermission()
                        }
                    }

                    Text("Get notified when connection quality changes")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(NetworkTheme.textTertiary)
                }

                if alertsEnabled {
                    Divider()
                        .background(NetworkTheme.textTertiary.opacity(0.2))

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Latency Alert")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(NetworkTheme.textSecondary)

                            Spacer()

                            Text(String(format: "%.0f ms", latencyThreshold))
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundStyle(NetworkTheme.textPrimary)
                        }

                        Slider(value: $latencyThreshold, in: 50...500, step: 10)
                            .tint(NetworkTheme.accent)

                        Text("Alert when latency exceeds this threshold")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(NetworkTheme.textTertiary)
                    }

                    Divider()
                        .background(NetworkTheme.textTertiary.opacity(0.2))

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Packet Loss Alert")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(NetworkTheme.textSecondary)

                            Spacer()

                            Text(String(format: "%.1f%%", packetLossThreshold))
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundStyle(NetworkTheme.textPrimary)
                        }

                        Slider(value: $packetLossThreshold, in: 1...20, step: 1)
                            .tint(NetworkTheme.accent)

                        Text("Alert when packet loss exceeds this threshold")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(NetworkTheme.textTertiary)
                    }

                    Divider()
                        .background(NetworkTheme.textTertiary.opacity(0.2))

                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: $alertOnNetworkChange) {
                            Text("Network Change Alerts")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(NetworkTheme.textSecondary)
                        }
                        .tint(NetworkTheme.accent)

                        Text("Get notified when switching between WiFi and Cellular")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(NetworkTheme.textTertiary)
                    }
                }
            }
        }
    }

    private var dataManagementSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 20) {
                sectionHeader(title: "Data Management")

                VStack(alignment: .leading, spacing: 8) {
                    Text("History Retention")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(NetworkTheme.textSecondary)

                    Picker("Retention", selection: $dataRetentionDays) {
                        Text("7 days").tag(7)
                        Text("30 days").tag(30)
                        Text("90 days").tag(90)
                    }
                    .pickerStyle(.segmented)
                    .tint(NetworkTheme.accent)
                }

                Divider()
                    .background(NetworkTheme.textTertiary.opacity(0.2))

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Total Sessions")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(NetworkTheme.textSecondary)

                        Spacer()

                        Text("\(sessions.count)")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundStyle(NetworkTheme.textPrimary)
                    }

                    Button(action: {
                        showClearHistoryAlert = true
                    }) {
                        Text("Clear All History")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(NetworkTheme.accentRed)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }

    private var aboutSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader(title: "About")

                HStack {
                    Text("Version")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(NetworkTheme.textSecondary)

                    Spacer()

                    Text("1.0.0")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(NetworkTheme.textPrimary)
                }

                Link(destination: URL(string: "https://github.com/davidbond17/pingpro")!) {
                    HStack {
                        Image(systemName: "link")
                        Text("View on GitHub")
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(NetworkTheme.accent)
                }
            }
        }
    }

    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(NetworkTheme.textPrimary)
            .textCase(.uppercase)
    }

    private func updateHost() {
        if PingService.shared.validateHost(tempHost) {
            targetHost = tempHost
        } else {
            showInvalidHostAlert = true
            tempHost = targetHost
        }
    }

    private func clearHistory() {
        for session in sessions {
            modelContext.delete(session)
        }
        try? modelContext.save()
    }

    private func requestNotificationPermission() {
        ConnectionAlertManager.shared.requestPermission { granted in
            if !granted {
                alertsEnabled = false
                showPermissionAlert = true
            }
        }
    }
}
