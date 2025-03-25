//
//  SignInEmailViewModel.swift
//  Momentm_
//
//  Created by matt on 10/11/24 with help from tutorials by Swiftful Thinking.
//

import Foundation

@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published private var errorMessage: String = ""
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var birthday = Date()
    public var gender = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty, !gender.isEmpty else {
            errorMessage = "Please fill out all fields."
            return
        }
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
        try await UserManager.shared.updateUserData(userId: user.userId, display_name: username, bio: nil, city: nil, birthday: birthday, gender: gender, weight: nil, height: nil)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}
