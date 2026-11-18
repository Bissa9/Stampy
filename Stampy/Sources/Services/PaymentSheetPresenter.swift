import UIKit
import Stripe
import StripePaymentSheet

enum PaymentSheetPresenter {
    @MainActor
    static func presentPaymentSheet(
        clientSecret: String,
        onResult: @escaping @Sendable (PaymentSheetResult) -> Void
    ) {
        guard StripeConfig.isPublishableKeyConfigured else {
            onResult(.failed(error: StripeConfigError.missingPublishableKey))
            return
        }
        StripeAPI.defaultPublishableKey = StripeConfig.publishableKey
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Stampy"
        let sheet = PaymentSheet(
            paymentIntentClientSecret: clientSecret,
            configuration: configuration
        )
        guard let presenter = UIApplication.shared.stampy_topViewController() else {
            return
        }
        sheet.present(from: presenter, completion: onResult)
    }
}

private extension UIApplication {
    @MainActor
    func stampy_topViewController() -> UIViewController? {
        let keyWindow = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        if let nav = top as? UINavigationController {
            return nav.visibleViewController ?? nav
        }
        if let tab = top as? UITabBarController {
            return tab.selectedViewController.flatMap { base in
                (base as? UINavigationController)?.visibleViewController ?? base
            }
        }
        return top
    }
}
