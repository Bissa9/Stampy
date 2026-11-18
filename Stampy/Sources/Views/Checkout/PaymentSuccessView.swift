import SwiftUI

struct PaymentSuccessView: View {
    let orderId: String
    let title: String
    let onTrack: () -> Void
    let onBackHome: () -> Void

    @State private var showWalkingLine = true
    @State private var lineProgress: CGFloat = 0
    @State private var showSuccessContent = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 20)

            if showWalkingLine {
                WalkingLineView(progress: lineProgress)
                    .frame(height: 8)
                    .padding(.horizontal, 32)
                    .transition(.opacity)
            }

            if showSuccessContent {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 76))
                        .foregroundStyle(StampyTheme.ink)
                        .symbolRenderingMode(.hierarchical)

                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Wait till your order comes home.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        Button(action: onTrack) {
                            Text("Track order")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(StampyTheme.ink)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(StampyTheme.ink, lineWidth: 2)
                                )
                        }

                        Button(action: onBackHome) {
                            Text("Back to home")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundStyle(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(StampyTheme.ink)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
                .transition(
                    .scale(scale: 0.92).combined(with: .opacity)
                )
            }

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                lineProgress = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
                withAnimation(.easeOut(duration: 0.25)) {
                    showWalkingLine = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                        showSuccessContent = true
                    }
                }
            }
        }
    }
}

private struct WalkingLineView: View {
    var progress: CGFloat

    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 0, y: geo.size.height / 2))
                path.addLine(
                    to: CGPoint(x: geo.size.width * progress, y: geo.size.height / 2)
                )
            }
            .stroke(
                StampyTheme.ink,
                style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [12, 10])
            )
        }
    }
}

#Preview {
    PaymentSuccessView(
        orderId: "preview",
        title: "Payment success",
        onTrack: {},
        onBackHome: {}
    )
}
