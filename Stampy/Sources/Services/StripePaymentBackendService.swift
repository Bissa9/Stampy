import Foundation
import FirebaseAuth
import FirebaseCore

enum StripePaymentBackendError: LocalizedError {
    case missingClientSecret
    case notSignedIn
    case serverMessage(String)

    var errorDescription: String? {
        switch self {
        case .missingClientSecret:
            return "Payment could not start. Try again."
        case .notSignedIn:
            return "You need to be signed in to pay with a card."
        case .serverMessage(let msg):
            return msg
        }
    }
}

final class StripePaymentBackendService {

    func createPaymentIntent(orderId: String) async throws -> String {
        guard FirebaseApp.app() != nil else {
            throw StripePaymentBackendError.serverMessage("App configuration error.")
        }
        guard let user = Auth.auth().currentUser else {
            throw StripePaymentBackendError.notSignedIn
        }
        let idToken = try await user.getIDToken(forcingRefresh: true)

        var request = URLRequest(url: StripeConfig.createPaymentIntentURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        let body: [String: String] = ["orderId": orderId]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw StripePaymentBackendError.serverMessage("Bad response from payment server.")
        }

        let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        let errString = ((json?["error"] as? String) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let serverError: String? = errString.isEmpty ? nil : errString

        if http.statusCode != 200 {
            if http.statusCode == 404, serverError == nil {
                throw StripePaymentBackendError.serverMessage(
                    "Payment endpoint not found (404). In Firebase Console → Functions, confirm `createPaymentIntentHttp` is deployed in \(StripeConfig.functionsRegion). Deploy with: firebase deploy --only functions --project \(StripeConfig.firebaseProjectId). If Functions shows a different URL than the app, update StripeConfig.createPaymentIntentURL to match."
                )
            }
            if let serverError {
                throw StripePaymentBackendError.serverMessage(serverError)
            }
            let textRaw = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let fallback = textRaw.isEmpty
                ? HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
                : textRaw
            throw StripePaymentBackendError.serverMessage(fallback)
        }

        guard let secret = json?["clientSecret"] as? String, !secret.isEmpty else {
            throw StripePaymentBackendError.missingClientSecret
        }
        return secret
    }
}
