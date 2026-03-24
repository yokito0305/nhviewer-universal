import UIKit
import Flutter
import WebKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let cookieChannel = FlutterMethodChannel(
            name: "samples.flutter.dev/cookies",
            binaryMessenger: controller.binaryMessenger
        )
        cookieChannel.setMethodCallHandler { [weak self] call, result in
            guard call.method == "readCloudflareCookies" else {
                result(FlutterMethodNotImplemented)
                return
            }
            self?.readCloudflareCookies(result: result)
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func readCloudflareCookies(result: @escaping FlutterResult) {
        let httpCookieStore = WKWebsiteDataStore.default().httpCookieStore
        let host = URL(string: "https://nhentai.net")?.host

        httpCookieStore.getAllCookies { cookies in
            let matchingCookies = cookies.filter { cookie in
                guard let host else { return false }
                return cookie.domain.contains(host) || host.contains(cookie.domain)
            }

            let cookieString = matchingCookies
                .map { "\($0.name)=\($0.value)" }
                .joined(separator: "; ")

            if cookieString.isEmpty {
                result(FlutterError(
                    code: "UNAVAILABLE",
                    message: "readCloudflareCookies error",
                    details: nil
                ))
            } else {
                result(cookieString)
            }
        }
    }
}
