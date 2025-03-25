//
//  FollowersView.swift
//  Momentm
//
//  Created by matt on 9/22/24.
//

import SwiftUI

struct FollowersView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var searchText = ""
    @State private var searchResults: [String] = []
    let userId: String
    
    var body: some View {
        NavigationStack {
            VStack {
//                TextField("Search followers", text: $searchText)
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(8)
//                    .padding(.horizontal)
//                    .onChange(of: searchText) { newValue in
//                        UserManager.shared.searchUsers(by: newValue)
//                    }
                
                List(searchResults, id: \.self) { userId in
                    NavigationLink(destination: ProfileView(userId: userId, isOwnProfile: userId == appState.currentUser?.uid)) {
                        UserRow(userId: userId)
                            .contentShape(Rectangle()) // Ensures the entire row is tappable
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Followers")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            Task {
                do {
                    searchResults = try await UserManager.shared.fetchFollowerIds(userId: userId)
                } catch {
                    print("Failed to fetch follower ids: \(error)")
                }
            }
            
        }
    }
}

struct FollowersView_Previews: PreviewProvider {
    static var previews: some View {
        FollowersView(userId: "VHAJFyMG1fgNhn65RuPG20FHkXA2")
    }
}
