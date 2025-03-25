////
////  FeedView.swift
////  Momentm
////
////  Created by matt on 9/18/24.
////
//
//import SwiftUI
//import Firebase
//import FirebaseAuth
//
//@MainActor
//final class FeedViewModel: ObservableObject {
//    @Published var authUser: AuthDataResultModel? = nil
//    
//    func loadAuthUser() {
//        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
//    }
//    
//    func getUser() async throws -> DBUser {
//        loadAuthUser()
//        guard let userId = authUser?.uid else {
//            throw NSError(domain: "GetUserError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated."])
//        }
//        let user = try await UserManager.shared.getUser(userId: userId)
//        return user
//
//    }
//}
//
//struct FeedView: View {
//    @EnvironmentObject var appState: AppState
//    
//    
//    @State private var showingLogActivity = false
//    @StateObject private var viewModel = FeedViewModel()
//    @State private var activities: [DBActivity] = []
//    @State private var user = DBUser?
//    
//    var body: some View {
//        NavigationStack {
//            ActivityScrollView(user: user)
//            .navigationTitle("Momentm")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("Momentm")
//                        .font(.system(size: 20, weight: .bold))
//                        .padding(.vertical, 5) // Adjust vertical padding
//                }
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        showingLogActivity.toggle()
//                    }) {
//                        ZStack {
//                            Circle()
//                                .fill(Color.black) // Circle background color
//                                .frame(width: 30, height: 30) // Size of the circle
//                            Image(systemName: "plus")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 20, height: 20) // Size of the plus icon
//                                .foregroundColor(.white) // Color of the icon
//                        }
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink(destination: UserSearchView()) {
//                        ZStack {
//                            Circle()
//                                .fill(Color.black) // Circle background color
//                                .frame(width: 30, height: 30) // Size of the circle
//                            Image(systemName: "magnifyingglass")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 20, height: 20) // Size of the plus icon
//                                .foregroundColor(.white) // Color of the icon
//                        }
//                    }
//                }
//            }
//            .sheet(isPresented: $showingLogActivity) {
//                LogActivityView()
//            }
//        }
//        .onAppear {
//            Task {
//                do {
//                    let authUser: AuthDataResultModel? = appState.currentUser
//                    user = UserManager.shared.getUser(userId: authUser?.uid)
//                } catch {
//                    print("Failed to fetch user: \(error)")
//                }
//            }
//        }
//        .toolbarBackground(Color.blue, for: .navigationBar)
//        .toolbarColorScheme(.light, for: .navigationBar)
//    }
//}
//
//struct FeedView_Previews: PreviewProvider {
//    static var previews: some View {
//        let user = DBUser(userId: "VHAJFyMG1fgNhn65RuPG20FHkXA2")
//        FeedView()
//    }
//}

//
//  FeedView.swift
//  Momentm
//
//  Created by matt on 9/18/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var authUser: AuthDataResultModel? = nil
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func getUser() async throws -> DBUser {
        loadAuthUser()
        guard let userId = authUser?.uid else {
            throw NSError(domain: "GetUserError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated."])
        }
        let user = try await UserManager.shared.getUser(userId: userId)
        return user

    }
}

struct FeedView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var showingLogActivity = false
    @State private var showingSpeechInput = false
    
    @StateObject private var viewModel = FeedViewModel()
    @State private var activities: [DBActivity] = []
    
    @State private var userIds: [String] = []
    
    var body: some View {
        NavigationStack {
            ActivityScrollView(userIds: userIds)
            .navigationTitle("Momentm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Momentm")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.vertical, 5) // Adjust vertical padding
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            showingLogActivity = true
                        }) {
                            Label("Manual Entry", systemImage: "square.and.pencil")
                        }
                        
                        Button(action: {
                            showingSpeechInput = true
                        }) {
                            Label("Voice Recording", systemImage: "mic.fill")
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 30, height: 30)
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: UserSearchView()) {
                        ZStack {
                            Circle()
                                .fill(Color.black) // Circle background color
                                .frame(width: 30, height: 30) // Size of the circle
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20) // Size of the plus icon
                                .foregroundColor(.white) // Color of the icon
                        }
                    }
                }
            }
            .sheet(isPresented: $showingLogActivity) {
                LogActivityView()
            }
            .sheet(isPresented: $showingSpeechInput) {
                SpeechToTextView()
            }
        }
        .onAppear {
            loadUserIds()
        }
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
    }
    
//    func openSpeechActivityRecorder() {
//        let speechActivityVC = SpeechActivityViewController()
//        let navController = UINavigationController(rootViewController: speechActivityVC)
//        present(navController, animated: true)
//    }
    
    private func loadUserIds() {
        Task {
            guard let authUserId = Auth.auth().currentUser?.uid else {
                print("No authenticated user ID found")
                return
            }
            let followingIds = try await UserManager.shared.fetchFollowingIds(userId: authUserId) // Fetch followings
            userIds = [authUserId] + followingIds // Include the authenticated user's ID
            print("user ids: \(userIds)")
        }
    }
//    private func loadUserIds() {
//        Task {
//            do {
//                guard let authUserId = Auth.auth().currentUser?.uid else { return }
//                let followingIds = try await UserManager.shared.getFollowing(userId: authUserId)
//                print("Followings: \(followingIds)")
//                userIds = [authUserId] + followingIds // Include the auth user's activities too
//            } catch {
//                print("Failed to fetch user IDs for feed: \(error)")
//            }
//        }
//    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
