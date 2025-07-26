import SwiftUI

struct PriceCardView: View {
    let instrument: FinancialInstrument
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with symbol and type
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(instrument.symbol)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(instrument.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(instrument.type.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    )
                    .foregroundColor(.blue)
            }
            
            // Price display
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(instrument.formattedPrice)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(instrument.currency)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !instrument.formattedChange.isEmpty {
                    Text(instrument.formattedChange)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(changeColor)
                }
            }
            
            // Last updated
            if let lastUpdated = instrument.lastUpdated {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("Updated \(lastUpdated, formatter: timeFormatter)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    private var changeColor: Color {
        guard let change = instrument.change else { return .secondary }
        return change >= 0 ? .green : .red
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

struct PriceCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            PriceCardView(instrument: FinancialInstrument.sampleData[0])
            PriceCardView(instrument: FinancialInstrument.sampleData[1])
            PriceCardView(instrument: FinancialInstrument.sampleData[2])
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}