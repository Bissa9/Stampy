//
//  StampRow.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 03/01/2026.
//
import SwiftUI

struct StampRow: View {
    let stamp: Stamp
    @EnvironmentObject var cartVM: CartViewModel
    private let cardWidth: CGFloat = 135
    private let textHeight: CGFloat = 70

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AsyncImage(url: URL(string: stamp.imageURL ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: cardWidth, height: 125)
            .cornerRadius(10)
            .clipped()

            VStack(alignment: .leading, spacing: 2) {

                Text(stamp.name)
                    .font(.headline)
                    .lineLimit(2)

                if let description = stamp.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                if let price = stamp.price {
                    Text("$\(price, specifier: "%.1f")")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }

            }
            .frame(height: textHeight, alignment: .top)
        }
        .frame(width: cardWidth)
        .overlay(alignment: .topTrailing) {
            Button {
                cartVM.toggleFavorite(stamp)
            } label: {
                Image(systemName: cartVM.isFavorite(stamp) ? "heart.fill" : "heart")
                    .foregroundStyle(cartVM.isFavorite(stamp) ? StampyTheme.ink : Color.white)
                    .padding(8)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(8)
        }
    }
}


#Preview {
    StampRow(
        stamp: Stamp(
            id: "1",
            name: "Vintage Stamp",
            description: "Old rare stamp",
            imageURL: nil
            
        )
    )
    .padding()
    .environmentObject(CartViewModel())
}
