import Foundation

enum StripeConfigError: LocalizedError {
    case missingPublishableKey

    var errorDescription: String? {
        switch self {
        case .missingPublishableKey:
            return "Add a Stripe publishable key in Config/Secrets.xcconfig and rebuild."
        }
    }
}

enum StripeConfig {
    /// Read from the generated Info.plist (`STRIPE_PUBLISHABLE_KEY` in Config/Secrets.xcconfig).
    /// A publishable key is safe to ship inside the app. It is kept out of git so the public repo
    /// does not pin a specific Stripe account.
    static var publishableKey: String {
        let raw = Bundle.main.object(forInfoDictionaryKey: "StripePublishableKey") as? String ?? ""
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("pk_"), !trimmed.contains("replace_me"), !trimmed.contains("$(") else {
            return ""
        }
        return trimmed
    }

    static var isPublishableKeyConfigured: Bool {
        !publishableKey.isEmpty
    }

    /// Must match `PROJECT_ID` in `GoogleService-Info.plist`.
    static let firebaseProjectId = "stampy-90571"

    /// Must match the region used in `functions/index.js` and `firebase functions:list`.
    static let functionsRegion = "us-central1"

    /// Default HTTPS URL for `createPaymentIntentHttp` (1st gen).
    private static var defaultCreatePaymentIntentURL: URL {
        URL(string: "https://\(functionsRegion)-\(firebaseProjectId).cloudfunctions.net/createPaymentIntentHttp")!
    }

    /// PaymentIntent HTTP endpoint. Optional override: Info key `StripePaymentIntentEndpointURL`.
    static var createPaymentIntentURL: URL {
        if let raw = Bundle.main.object(forInfoDictionaryKey: "StripePaymentIntentEndpointURL") as? String {
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty, !trimmed.contains("$("), let url = URL(string: trimmed) {
                return url
            }
        }
        return defaultCreatePaymentIntentURL
    }
}
