import SwiftUI

struct MyStampsView: View {
    @EnvironmentObject var cartVM: CartViewModel

    var body: some View {
        ScrollView {
            if cartVM.purchasedStamps.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "shippingbox")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                    Text("No purchased stamps yet")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 280)
            } else {
                StampsList(stamps: cartVM.purchasedStamps)
                    .padding(.top, 10)
            }
        }
        .navigationTitle("My Stamps")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MyStampsView()
            .environmentObject(CartViewModel())
    }
}
