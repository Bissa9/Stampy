import SwiftUI

struct BalanceView: View {
    let balance: Double

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "wallet.pass")
                .font(.system(size: 38))
                .foregroundStyle(StampyTheme.ink)

            Text("Current Balance")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(String(format: "$%.2f", balance))
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 60)
        .navigationTitle("Balance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        BalanceView(balance: 0)
    }
}
