//
//  momentumApp.swift
//  momentum
//
//  Created by matt on 10/2/24.
//

import SwiftUI

@main
struct momentumApp: App {
    @UIApplicationDelegateAdaptor(momentumAppDelegate.self) var appDelegate

    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.isAuthenticated {
                ContentView()
                    .environmentObject(appState)
            } else {
                SignInView()
                    .environmentObject(appState)
            }
        }
    }
}
