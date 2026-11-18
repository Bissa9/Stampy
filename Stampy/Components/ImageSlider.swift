//
//  ImageSlider.swift
//  Stampy
//
//  Created by Ebtisam Khalid on 09/01/2026.
//

import SwiftUI

struct ImageSlider: View {
    let images = ["inkrubber", "50", "paris"]
    @State private var currentIndex = 0

    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 8) {
            TabView(selection: $currentIndex) {
                ForEach(images.indices, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 168)
                        .clipped()
                        .tag(index)
                }
            }
            .frame(height: 168)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onReceive(timer) { _ in
                withAnimation {
                    currentIndex = (currentIndex + 1) % images.count
                }
            }

            HStack(spacing: 6) {
                ForEach(images.indices, id: \.self) { index in
                    Image(systemName: index == currentIndex ? "circle.fill" : "circle")
                        .font(.system(size: 8))
                        .foregroundStyle(StampyTheme.ink)
                }
            }
        }
    }
}

#Preview {
    ImageSlider()
        .padding()
        .background(StampyTheme.paper)
}
