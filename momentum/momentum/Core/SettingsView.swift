//
//  SettingsView.swift
//  Momentm_
//
//  Created by matt on 10/11/24 with help from tutorials by Swiftful Thinking.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    await appState.signOut()
                }
            }
            
            Button(role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Delete account")
            }
            
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
        }
        .onAppear {
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
        }
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(showSignInView: .constant(false))
        }
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
            Button("Reset password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("PASSWORD RESET!")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Update password") {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        print("PASSWORD UPDATED!")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Update email") {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("EMAIL UPDATED!")
                    } catch {
                        print(error)
                    }
                }
            }
        } header: {
            Text("Email functions")
        }
    }
    
//    private var anonymousSection: some View {
//        Section {
//            Button("Link Google Account") {
//                Task {
//                    do {
//                        try await viewModel.linkGoogleAccount()
//                        print("GOOGLE LINKED!")
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//            
//            Button("Link Apple Account") {
//                Task {
//                    do {
//                        try await viewModel.linkAppleAccount()
//                        print("APPLE LINKED!")
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//            
//            Button("Link Email Account") {
//                Task {
//                    do {
//                        try await viewModel.linkEmailAccount()
//                        print("EMAIL LINKED!")
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//        } header: {
//            Text("Create account")
//        }
//    }
}
