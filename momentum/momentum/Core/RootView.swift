//
//  RootView.swift
//  Momentm_
//
//  Created by matt on 10/11/24 with help from tutorials by Swiftful Thinking.
//

import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @State private var userId = ""
    
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Feed")
                }
            
//            SpotifyView()
//                .tabItem {
//                    Image(systemName: "music.note")
//                    Text("Music")
//                }
            
            ProfileView(userId: userId, isOwnProfile: userId == Auth.auth().currentUser?.uid)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            Task {
                guard let userid = authUser?.uid else {
                    print("User ID is nil")
                    return
                }
                userId = userid
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
