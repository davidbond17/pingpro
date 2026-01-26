import Foundation

final class PingService {
    static let shared = PingService()

    private init() {}

    func ping(host: String, timeout: TimeInterval = 5.0, networkType: NetworkType) async -> PingResult {
        guard let url = buildURL(from: host) else {
            return PingResult(
                latency: nil,
                host: host,
                networkType: networkType,
                didSucceed: false
            )
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = timeout
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let startTime = Date()

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return PingResult(
                    latency: nil,
                    host: host,
                    networkType: networkType,
                    didSucceed: false
                )
            }

            let latency = Date().timeIntervalSince(startTime) * 1000

            return PingResult(
                latency: latency,
                host: host,
                networkType: networkType,
                didSucceed: true
            )
        } catch {
            return PingResult(
                latency: nil,
                host: host,
                networkType: networkType,
                didSucceed: false
            )
        }
    }

    private func buildURL(from host: String) -> URL? {
        let cleanHost = host.trimmingCharacters(in: .whitespaces)

        if cleanHost.hasPrefix("http://") || cleanHost.hasPrefix("https://") {
            return URL(string: cleanHost)
        }

        if cleanHost.contains(":") && !cleanHost.hasPrefix("[") {
            return URL(string: "https://\(cleanHost)")
        }

        return URL(string: "https://\(cleanHost)")
    }

    func validateHost(_ host: String) -> Bool {
        let cleanHost = host.trimmingCharacters(in: .whitespaces)

        if cleanHost.isEmpty {
            return false
        }

        if let url = buildURL(from: cleanHost), url.host != nil {
            return true
        }

        let ipPattern = "^([0-9]{1,3}\\.){3}[0-9]{1,3}$"
        if let regex = try? NSRegularExpression(pattern: ipPattern) {
            let range = NSRange(location: 0, length: cleanHost.utf16.count)
            if regex.firstMatch(in: cleanHost, range: range) != nil {
                return true
            }
        }

        return false
    }
}
