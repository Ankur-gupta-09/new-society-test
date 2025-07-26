import Foundation
import Network

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    @Published var isConnected = true
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    // MARK: - Generic API Request Method
    func request<T: Codable>(
        url: URL,
        type: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        guard isConnected else {
            throw NetworkError.noConnection
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    // MARK: - Specific API Methods
    func fetchForexRates() async throws -> ForexResponse {
        let url = URL(string: "https://api.exchangerate-api.com/v4/latest/AUD")!
        return try await request(url: url, type: ForexResponse.self)
    }
    
    func fetchBitcoinPrice() async throws -> [String: Any] {
        let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd&include_24hr_change=true")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NetworkError.invalidData
        }
        
        return json
    }
    
    func fetchGoldPrice() async throws -> [String: Any] {
        // Using a free API for gold prices
        let url = URL(string: "https://api.metals.live/v1/spot/gold")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NetworkError.invalidData
        }
        
        return json
    }
    
    func fetchStockIndex(symbol: String) async throws -> [String: Any] {
        // Yahoo Finance alternative endpoint
        let url = URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/\(symbol)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NetworkError.invalidData
        }
        
        return json
    }
}

// MARK: - Network Error Types
enum NetworkError: LocalizedError {
    case noConnection
    case invalidURL
    case invalidResponse
    case invalidData
    case httpError(Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection available"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Invalid data received"
        case .httpError(let code):
            return "HTTP error with status code: \(code)"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        }
    }
}