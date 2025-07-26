import Foundation

// MARK: - Financial Instrument Model
struct FinancialInstrument: Identifiable, Codable {
    let id = UUID()
    let symbol: String
    let name: String
    let type: InstrumentType
    var currentPrice: Double?
    var previousPrice: Double?
    var change: Double?
    var changePercent: Double?
    var lastUpdated: Date?
    var currency: String
    
    enum InstrumentType: String, CaseIterable {
        case forex = "Forex"
        case commodity = "Commodity"
        case cryptocurrency = "Cryptocurrency"
        case index = "Index"
        case indicator = "Economic Indicator"
    }
    
    var priceChangeColor: String {
        guard let change = change else { return "gray" }
        return change >= 0 ? "green" : "red"
    }
    
    var formattedPrice: String {
        guard let price = currentPrice else { return "Loading..." }
        
        switch type {
        case .forex:
            return String(format: "%.4f", price)
        case .commodity:
            return String(format: "$%.2f", price)
        case .cryptocurrency:
            return String(format: "$%.2f", price)
        case .index:
            return String(format: "%.2f", price)
        case .indicator:
            return String(format: "%.2f", price)
        }
    }
    
    var formattedChange: String {
        guard let change = change, let changePercent = changePercent else { return "" }
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", change)) (\(sign)\(String(format: "%.2f", changePercent))%)"
    }
}

// MARK: - API Response Models
struct ForexResponse: Codable {
    let success: Bool
    let rates: [String: Double]
}

struct CryptocurrencyResponse: Codable {
    let data: [String: CryptoData]
    
    struct CryptoData: Codable {
        let quote: [String: Quote]
        
        struct Quote: Codable {
            let price: Double
            let percent_change_24h: Double
        }
    }
}

struct YahooFinanceResponse: Codable {
    let quoteResponse: QuoteResponse
    
    struct QuoteResponse: Codable {
        let result: [QuoteResult]
    }
    
    struct QuoteResult: Codable {
        let regularMarketPrice: Double?
        let regularMarketChange: Double?
        let regularMarketChangePercent: Double?
        let regularMarketPreviousClose: Double?
    }
}

// MARK: - Sample Data
extension FinancialInstrument {
    static let sampleData: [FinancialInstrument] = [
        FinancialInstrument(
            symbol: "AUDUSD",
            name: "AUD/USD",
            type: .forex,
            currentPrice: 0.6450,
            previousPrice: 0.6420,
            change: 0.0030,
            changePercent: 0.47,
            lastUpdated: Date(),
            currency: "USD"
        ),
        FinancialInstrument(
            symbol: "XAUUSD",
            name: "Gold",
            type: .commodity,
            currentPrice: 2050.30,
            previousPrice: 2035.80,
            change: 14.50,
            changePercent: 0.71,
            lastUpdated: Date(),
            currency: "USD"
        ),
        FinancialInstrument(
            symbol: "BTC",
            name: "Bitcoin",
            type: .cryptocurrency,
            currentPrice: 42500.00,
            previousPrice: 41200.00,
            change: 1300.00,
            changePercent: 3.16,
            lastUpdated: Date(),
            currency: "USD"
        )
    ]
}