//
//  StampsList.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 03/01/2026.
//

import SwiftUI

struct StampsList: View {
    let stamps: [Stamp]
    /// Two columns, top-leading aligned (same as Home).
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12, alignment: .topLeading),
        GridItem(.flexible(), spacing: 12, alignment: .topLeading)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
            ForEach(stamps) { stamp in
                NavigationLink {
                    StampDetailView(stamp: stamp)
                        .frame(maxWidth: .infinity)
                } label: {
                    StampRow(stamp: stamp)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.horizontal)
    }
    
}

#Preview {
    StampsList(
            stamps: [
                Stamp(id: "1", name: "Vintage Stamp", description: "Old rare stamp", quantity: 1),
                Stamp(id: "2", name: "Modern Stamp", description: "Clean modern design", quantity: 1)
            ]
        )
}
