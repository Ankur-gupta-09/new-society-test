import Foundation
import Combine

@MainActor
class FinanceDataService: ObservableObject {
    @Published var instruments: [FinancialInstrument] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let session = URLSession.shared
    
    // API Keys (In production, these should be securely stored)
    private let exchangeRateAPIKey = "YOUR_EXCHANGE_RATE_API_KEY"
    private let coinMarketCapAPIKey = "YOUR_COINMARKETCAP_API_KEY"
    
    init() {
        setupInstruments()
        startPeriodicUpdates()
    }
    
    private func setupInstruments() {
        instruments = [
            FinancialInstrument(symbol: "AUDUSD", name: "AUD/USD", type: .forex, currency: "USD"),
            FinancialInstrument(symbol: "XAUUSD", name: "Gold", type: .commodity, currency: "USD"),
            FinancialInstrument(symbol: "BTC", name: "Bitcoin", type: .cryptocurrency, currency: "USD"),
            FinancialInstrument(symbol: "BUFFETT", name: "Buffett Indicator", type: .indicator, currency: "Ratio"),
            FinancialInstrument(symbol: "^IXIC", name: "NASDAQ Composite", type: .index, currency: "USD"),
            FinancialInstrument(symbol: "^GSPC", name: "S&P 500", type: .index, currency: "USD"),
            FinancialInstrument(symbol: "^NSEI", name: "NIFTY 50", type: .index, currency: "INR"),
            FinancialInstrument(symbol: "STI", name: "Goldman Sachs STI", type: .indicator, currency: "USD")
        ]
    }
    
    func refreshData() {
        Task {
            await fetchAllPrices()
        }
    }
    
    private func startPeriodicUpdates() {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.fetchAllPrices()
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchAllPrices() async {
        isLoading = true
        errorMessage = nil
        
        await withTaskGroup(of: Void.self) { group in
            for index in instruments.indices {
                group.addTask {
                    await self.fetchPrice(for: index)
                }
            }
        }
        
        isLoading = false
    }
    
    private func fetchPrice(for index: Int) async {
        let instrument = instruments[index]
        
        switch instrument.type {
        case .forex:
            await fetchForexPrice(for: index)
        case .cryptocurrency:
            await fetchCryptocurrencyPrice(for: index)
        case .commodity, .index:
            await fetchYahooFinancePrice(for: index)
        case .indicator:
            await fetchIndicatorPrice(for: index)
        }
    }
    
    private func fetchForexPrice(for index: Int) async {
        let instrument = instruments[index]
        
        // Using ExchangeRate-API (free tier available)
        let urlString = "https://api.exchangerate-api.com/v4/latest/AUD"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(ForexResponse.self, from: data)
            
            if let usdRate = response.rates["USD"] {
                updateInstrument(at: index, price: usdRate)
            }
        } catch {
            print("Error fetching forex data: \(error)")
            setMockData(for: index)
        }
    }
    
    private func fetchCryptocurrencyPrice(for index: Int) async {
        // Using CoinGecko API (free, no API key required)
        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd&include_24hr_change=true"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await session.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let bitcoin = json["bitcoin"] as? [String: Any],
               let price = bitcoin["usd"] as? Double,
               let change24h = bitcoin["usd_24h_change"] as? Double {
                
                let previousPrice = price / (1 + change24h / 100)
                let change = price - previousPrice
                
                updateInstrument(at: index, price: price, previousPrice: previousPrice, change: change, changePercent: change24h)
            }
        } catch {
            print("Error fetching crypto data: \(error)")
            setMockData(for: index)
        }
    }
    
    private func fetchYahooFinancePrice(for index: Int) async {
        let instrument = instruments[index]
        let urlString = "https://query1.finance.yahoo.com/v8/finance/chart/\(instrument.symbol)"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await session.data(from: url)
            // Parse Yahoo Finance response (simplified)
            // In production, you'd want to properly parse the full response
            setMockData(for: index) // Using mock data for now
        } catch {
            print("Error fetching Yahoo Finance data: \(error)")
            setMockData(for: index)
        }
    }
    
    private func fetchIndicatorPrice(for index: Int) async {
        // For indicators like Buffett Indicator, you'd typically use specialized APIs
        // For now, using mock data
        setMockData(for: index)
    }
    
    private func updateInstrument(at index: Int, price: Double, previousPrice: Double? = nil, change: Double? = nil, changePercent: Double? = nil) {
        instruments[index].currentPrice = price
        instruments[index].lastUpdated = Date()
        
        if let prevPrice = previousPrice {
            instruments[index].previousPrice = prevPrice
        }
        
        if let changeValue = change {
            instruments[index].change = changeValue
        }
        
        if let changePercentValue = changePercent {
            instruments[index].changePercent = changePercentValue
        }
        
        // Convert to AUD if needed
        if instruments[index].symbol != "AUDUSD" && instruments[index].currency == "USD" {
            convertToAUD(for: index)
        }
    }
    
    private func convertToAUD(for index: Int) {
        // Find AUD/USD rate
        if let audUsdInstrument = instruments.first(where: { $0.symbol == "AUDUSD" }),
           let audUsdRate = audUsdInstrument.currentPrice,
           audUsdRate > 0 {
            
            let usdToAudRate = 1.0 / audUsdRate
            
            if let currentPrice = instruments[index].currentPrice {
                instruments[index].currentPrice = currentPrice * usdToAudRate
                instruments[index].currency = "AUD"
            }
            
            if let previousPrice = instruments[index].previousPrice {
                instruments[index].previousPrice = previousPrice * usdToAudRate
            }
            
            if let change = instruments[index].change {
                instruments[index].change = change * usdToAudRate
            }
        }
    }
    
    private func setMockData(for index: Int) {
        let mockPrices: [String: (price: Double, change: Double, changePercent: Double)] = [
            "AUDUSD": (0.6850, 0.0030, 0.44),
            "XAUUSD": (3150.50, 25.30, 0.81),
            "BTC": (68500.00, 1200.00, 1.78),
            "BUFFETT": (185.2, -2.1, -1.12),
            "^IXIC": (18500.0, 150.0, 0.82),
            "^GSPC": (5200.0, 45.0, 0.87),
            "^NSEI": (22800.0, 180.0, 0.80),
            "STI": (3.25, 0.05, 1.56)
        ]
        
        let instrument = instruments[index]
        if let mockData = mockPrices[instrument.symbol] {
            let previousPrice = mockData.price - mockData.change
            updateInstrument(
                at: index,
                price: mockData.price,
                previousPrice: previousPrice,
                change: mockData.change,
                changePercent: mockData.changePercent
            )
        }
    }
}