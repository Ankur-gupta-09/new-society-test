# Finance Price Tracker - iOS App

A modern SwiftUI-based iPhone app that displays real-time prices of various financial instruments, including AUDUSD, Gold, Bitcoin, market indices, and economic indicators with prices shown in AUD where applicable.

## Features

### 📊 Financial Instruments Covered
- **AUD/USD** - Australian Dollar to US Dollar forex pair
- **Gold (XAUUSD)** - Gold spot price in USD (converted to AUD)
- **Bitcoin (BTC)** - Bitcoin price in USD (converted to AUD)
- **Buffett Indicator** - Market valuation indicator
- **NASDAQ Composite** - Technology-heavy stock market index
- **S&P 500** - US stock market index
- **NIFTY 50** - NSE India stock index
- **Goldman Sachs STI** - Singapore index indicator

### 🚀 App Features
- **Real-time Price Updates** - Automatic refresh every 60 seconds
- **Pull-to-Refresh** - Manual refresh capability
- **Search & Filter** - Find specific instruments quickly
- **AUD Conversion** - Automatic conversion of USD prices to AUD
- **Price Change Indicators** - Visual indicators for gains/losses
- **Modern UI Design** - Clean, intuitive SwiftUI interface
- **Market Status** - Live market status display
- **Summary Dashboard** - Quick overview of gainers and losers

### 📱 Technical Features
- **SwiftUI** - Modern iOS development framework
- **Combine Framework** - Reactive programming for data updates
- **Async/Await** - Modern concurrency for API calls
- **MVVM Architecture** - Clean separation of concerns
- **Dark Mode Support** - Automatic adaptation to system theme
- **Accessibility** - VoiceOver and accessibility features

## Installation

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- macOS for development

### Setup
1. Clone or download the project
2. Open `FinancePriceTracker.xcodeproj` in Xcode
3. Select your development team in Project Settings
4. Build and run on iOS Simulator or device

## API Integration

The app integrates with several financial data APIs:

### Free APIs Used
- **ExchangeRate-API** - For AUD/USD forex rates
- **CoinGecko API** - For cryptocurrency prices (no API key required)
- **Yahoo Finance API** - For stock indices and commodities

### API Setup (Optional)
For production use, consider getting API keys for:
- ExchangeRate-API (free tier available)
- Alpha Vantage (for more reliable stock data)
- CoinMarketCap (for additional crypto data)

Add your API keys to `FinanceDataService.swift`:
```swift
private let exchangeRateAPIKey = "YOUR_API_KEY_HERE"
private let coinMarketCapAPIKey = "YOUR_API_KEY_HERE"
```

## Architecture

### Project Structure
```
FinancePriceTracker/
├── FinancePriceTrackerApp.swift    # App entry point
├── ContentView.swift               # Main view
├── FinanceModel.swift             # Data models
├── FinanceDataService.swift       # API service layer
├── PriceCardView.swift           # Reusable UI component
└── Assets.xcassets/              # App assets
```

### Data Flow
1. `FinanceDataService` fetches data from various APIs
2. Data is processed and converted to AUD where applicable
3. SwiftUI views automatically update via `@Published` properties
4. UI reflects real-time price changes with color-coded indicators

## Customization

### Adding New Instruments
To add new financial instruments:

1. Add to `setupInstruments()` in `FinanceDataService.swift`:
```swift
FinancialInstrument(
    symbol: "NEW_SYMBOL",
    name: "Display Name",
    type: .forex, // or .commodity, .cryptocurrency, .index, .indicator
    currency: "USD"
)
```

2. Add mock data in `setMockData()` method
3. Implement API fetching logic if needed

### Styling Customization
- Modify colors in `PriceCardView.swift` and `ContentView.swift`
- Adjust fonts, spacing, and layout as needed
- Update accent color in `Assets.xcassets/AccentColor.colorset`

## Performance Considerations

- **Efficient Updates**: Uses SwiftUI's declarative updates
- **Background Processing**: API calls run on background queues
- **Memory Management**: Proper use of weak references and cancellables
- **Network Optimization**: Concurrent API calls for faster loading

## Error Handling

- **Network Failures**: Falls back to mock data when APIs are unavailable
- **Invalid Data**: Graceful handling of malformed API responses
- **Rate Limiting**: Respects API rate limits with proper timing

## Future Enhancements

### Planned Features
- [ ] Watchlist functionality
- [ ] Price alerts and notifications
- [ ] Historical price charts
- [ ] Portfolio tracking
- [ ] Widget support for iOS home screen
- [ ] Apple Watch companion app
- [ ] Offline data caching
- [ ] Additional technical indicators

### Technical Improvements
- [ ] Core Data for local storage
- [ ] Background app refresh
- [ ] Network reachability monitoring
- [ ] Improved error handling and retry logic
- [ ] Unit and UI testing
- [ ] Continuous Integration setup

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add appropriate tests
5. Submit a pull request

## License

This project is open source and available under the MIT License.

## Disclaimer

This app is for informational purposes only. Financial data may be delayed or inaccurate. Always consult professional financial advisors for investment decisions.

## Support

For issues, feature requests, or questions:
- Create an issue on the repository
- Contact the development team

---

**Built with SwiftUI for iOS** 📱💰📊