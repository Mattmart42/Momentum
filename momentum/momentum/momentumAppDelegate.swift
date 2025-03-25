//
//  momentumAppDelegate.swift
//  momentum
//
//  Created by matt on 10/3/24.
//

import Foundation
import UIKit

import Firebase

class momentumAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Opened URL in AppDelegate: \(url.absoluteString)")
        //SpotifyAuthManager.shared.handleCallback(url: url)
        return true
    }
}


func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
    
}
