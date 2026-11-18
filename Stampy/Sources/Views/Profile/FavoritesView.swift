import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var cartVM: CartViewModel

    var body: some View {
        ScrollView {
            if cartVM.favoriteStamps.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "heart")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                    Text("No favorites yet")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 280)
            } else {
                StampsList(stamps: cartVM.favoriteStamps)
                    .padding(.top, 10)
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
            .environmentObject(CartViewModel())
    }
}
