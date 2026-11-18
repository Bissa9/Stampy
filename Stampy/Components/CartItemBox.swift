//
//  CartItemBox.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 21/02/2026.
//

import SwiftUI

struct CartItemBox: View {
    let stamp: Stamp
    let onIncrease: () -> Void
    let onDecrease: () -> Void
    
    private let cardWidth: CGFloat = 96
    
    var body: some View {
        HStack(spacing: 12) {
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
            .frame(width: cardWidth, height: cardWidth)
            .cornerRadius(10)
            .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(stamp.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("$\((stamp.price ?? 0), specifier: "%.2f") each")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 10) {
                    Button(action: onDecrease) {
                        Image(systemName: "minus")
                            .font(.caption.weight(.bold))
                            .frame(width: 28, height: 28)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    Text("\(stamp.quantity)")
                        .font(.subheadline.weight(.semibold))
                        .frame(minWidth: 20)
                    
                    Button(action: onIncrease) {
                        Image(systemName: "plus")
                            .font(.caption.weight(.bold))
                            .frame(width: 28, height: 28)
                            .background(StampyTheme.ink.opacity(0.15))
                            .foregroundStyle(StampyTheme.ink)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer()
            Text("$\((Double(stamp.quantity) * (stamp.price ?? 0)), specifier: "%.2f")")
                .font(.subheadline.weight(.semibold))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CartItemBox(
        stamp: Stamp(
            id: "1",
            name: "Vintage Stamppp",
            description: "Old rare stamp",
            price: 12.5,
            imageURL: nil
        ),
        onIncrease: {},
        onDecrease: {}
    )
}
