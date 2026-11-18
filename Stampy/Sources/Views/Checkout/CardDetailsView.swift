import SwiftUI

struct CardDetailsView: View {
    let isProcessing: Bool
    let onPayNow: () -> Void

    @State private var cardNumber = ""
    @State private var cardholderName = ""
    @State private var expiryDate = ""
    @State private var cvv = ""

    var body: some View {
        Form {
            Section("Card information") {
                TextField("Card number", text: $cardNumber)
                    .keyboardType(.numberPad)
                    .onChange(of: cardNumber) { _, newValue in
                        cardNumber = formatCardNumber(newValue)
                    }

                TextField("Cardholder name", text: $cardholderName)
                    .textInputAutocapitalization(.words)

                HStack {
                    TextField("MM/YY", text: $expiryDate)
                        .keyboardType(.numberPad)
                        .onChange(of: expiryDate) { _, newValue in
                            expiryDate = formatExpiryDate(newValue)
                        }

                    TextField("CVV", text: $cvv)
                        .keyboardType(.numberPad)
                        .onChange(of: cvv) { _, newValue in
                            cvv = String(newValue.filter(\.isNumber).prefix(4))
                        }
                }
            }

            Section {
                Button {
                    onPayNow()
                } label: {
                    if isProcessing {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 44)
                    } else {
                        Text("Pay now")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                }
                .disabled(!isFormValid || isProcessing)
            }
        }
        .navigationTitle("Card details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var isFormValid: Bool {
        let digits = cardNumber.filter(\.isNumber)
        let hasValidCard = digits.count >= 12 && digits.count <= 19
        let hasValidName = !cardholderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasValidExpiry = expiryDate.count == 5
        let hasValidCVV = cvv.count == 3 || cvv.count == 4
        return hasValidCard && hasValidName && hasValidExpiry && hasValidCVV
    }

    private func formatCardNumber(_ value: String) -> String {
        let digits = value.filter(\.isNumber).prefix(19)
        var formatted = ""
        for (index, char) in digits.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted.append(" ")
            }
            formatted.append(char)
        }
        return formatted
    }

    private func formatExpiryDate(_ value: String) -> String {
        let digits = String(value.filter(\.isNumber).prefix(4))
        if digits.count <= 2 {
            return digits
        }
        let month = digits.prefix(2)
        let year = digits.suffix(digits.count - 2)
        return "\(month)/\(year)"
    }
}

#Preview {
    NavigationStack {
        CardDetailsView(isProcessing: false, onPayNow: {})
    }
}
