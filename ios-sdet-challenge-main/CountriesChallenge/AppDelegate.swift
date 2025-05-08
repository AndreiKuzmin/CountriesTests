//
//  AppDelegate.swift
//  CountriesChallenge
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Add this check for UI testing
        if ProcessInfo.processInfo.arguments.contains("-uitesting") {
            // Clear user defaults, cache, or other test setup
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = createNavigationViewController()
        window!.makeKeyAndVisible()
        return true
    }

    private func createNavigationViewController() -> UINavigationController {
        return UINavigationController(rootViewController: CountriesViewController())
    }
}
