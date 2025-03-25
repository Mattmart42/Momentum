//
//  AppState.swift
//  Momentm_
//
//  Created by Matthew Martinez on 11/22/24.
//

import Foundation
import FirebaseAuth

@MainActor
class AppState: ObservableObject {
    @Published var currentUser: AuthDataResultModel? = nil
    @Published var isAuthenticated: Bool = false

    private let authManager = AuthenticationManager.shared

    init() {
        Task {
            await checkAuthStatus()
        }
    }

    func checkAuthStatus() async {
        do {
            let user = try authManager.getAuthenticatedUser()
            self.currentUser = user
            self.isAuthenticated = true
        } catch {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }

    func signOut() async {
        do {
            try authManager.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    func signIn(email: String, password: String) async {
        do {
            let user = try await authManager.signInUser(email: email, password: password)
            self.currentUser = user
            self.isAuthenticated = true
        } catch {
            print("Error signing in: \(error.localizedDescription)")
        }
    }

    func signUp(email: String, password: String, username: String, birthday: Date, gender: String) async {
        do {
            let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password) //gets the auth data result from the authManager
            self.currentUser = authDataResult //sets the current user from the auth
            let DBUser = DBUser(auth: authDataResult) //sets the dbuser from the auth
            try await UserManager.shared.createNewUser(user: DBUser) //creates a DBUser with id from auth
            try await UserManager.shared.updateUserData(userId: DBUser.userId, display_name: username, bio: nil, city: nil, birthday: birthday, gender: gender, weight: nil, height: nil) //updates required data in the DB
            self.isAuthenticated = true //tracks if the user is authenticated
            
        } catch {
            print("Error creating account: \(error.localizedDescription)")
        }
    }
}
