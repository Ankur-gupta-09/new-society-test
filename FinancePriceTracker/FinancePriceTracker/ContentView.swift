import SwiftUI

struct ContentView: View {
    @StateObject private var dataService = FinanceDataService()
    @State private var searchText = ""
    @State private var selectedFilter: FinancialInstrument.InstrumentType? = nil
    @State private var showingFilterSheet = false
    
    var filteredInstruments: [FinancialInstrument] {
        var filtered = dataService.instruments
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { instrument in
                instrument.name.localizedCaseInsensitiveContains(searchText) ||
                instrument.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply type filter
        if let selectedFilter = selectedFilter {
            filtered = filtered.filter { $0.type == selectedFilter }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header section
                    headerSection
                    
                    // Main content
                    if dataService.instruments.isEmpty && dataService.isLoading {
                        loadingView
                    } else if filteredInstruments.isEmpty {
                        emptyStateView
                    } else {
                        instrumentsList
                    }
                }
            }
            .navigationTitle("Finance Tracker")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilterSheet = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        dataService.refreshData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search instruments...")
            .sheet(isPresented: $showingFilterSheet) {
                filterSheet
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Market status banner
            marketStatusBanner
            
            // Summary cards
            summaryCards
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private var marketStatusBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Market Status")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text("Markets Open")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Last Updated")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(Date(), formatter: timeFormatter)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
        )
    }
    
    private var summaryCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                SummaryCard(
                    title: "Total Instruments",
                    value: "\(dataService.instruments.count)",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
                
                SummaryCard(
                    title: "Gainers",
                    value: "\(gainersCount)",
                    icon: "arrow.up.circle.fill",
                    color: .green
                )
                
                SummaryCard(
                    title: "Losers",
                    value: "\(losersCount)",
                    icon: "arrow.down.circle.fill",
                    color: .red
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var instrumentsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredInstruments) { instrument in
                    PriceCardView(instrument: instrument)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
        .refreshable {
            dataService.refreshData()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading market data...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No instruments found")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Try adjusting your search or filter criteria")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Clear Filters") {
                searchText = ""
                selectedFilter = nil
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var filterSheet: some View {
        NavigationView {
            List {
                Section("Filter by Type") {
                    ForEach(FinancialInstrument.InstrumentType.allCases, id: \.self) { type in
                        HStack {
                            Text(type.rawValue)
                            Spacer()
                            if selectedFilter == type {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFilter = selectedFilter == type ? nil : type
                        }
                    }
                }
                
                Section {
                    Button("Clear All Filters") {
                        selectedFilter = nil
                        searchText = ""
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingFilterSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private var gainersCount: Int {
        dataService.instruments.filter { instrument in
            guard let change = instrument.change else { return false }
            return change > 0
        }.count
    }
    
    private var losersCount: Int {
        dataService.instruments.filter { instrument in
            guard let change = instrument.change else { return false }
            return change < 0
        }.count
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 120, height: 80)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}