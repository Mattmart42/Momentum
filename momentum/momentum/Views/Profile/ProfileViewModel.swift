//
//  ProfileViewModel.swift
//  Momentm_
//
//  Created by Matthew Martinez on 11/10/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var authUser: AuthDataResultModel? = nil
    
    func getUser() async throws -> DBUser {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
        guard let userId = authUser?.uid else {
            throw NSError(domain: "GetUserError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated."])
        }
        let user = try await UserManager.shared.getUser(userId: userId)
        return user
    }
}
