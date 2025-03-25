//
//  UserSearchView.swift
//  Momentm_
//
//  Created by Matthew Martinez on 11/14/24.
//

import SwiftUI
import FirebaseAuth

struct UserSearchView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search for athletes", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onChange(of: searchText) { newValue in
                        UserManager.shared.searchUsers(by: newValue)
                    }
                
                List(UserManager.shared.searchResults, id: \.userId) { user in
                    NavigationLink(destination: ProfileView(userId: user.userId, isOwnProfile: user.userId == Auth.auth().currentUser?.uid)) {
                        UserRow(userId: user.userId)
                            .contentShape(Rectangle()) // Ensures the entire row is tappable
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("User Search")
        }
//        .onAppear {
//            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
//            Task {
//                guard let userId = authUser?.uid else {
//                    print("User ID is nil")
//                    return
//                }
//                user = try await UserManager.shared.getUser(userId: userId)
//            }
//        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool

    var body: some View {
        HStack {
            TextField("Search for athletes", text: $text)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Spacer()
                        if !text.isEmpty {
                            Button(action: { text = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.vertical, 5)
        }
    }
}

struct UserRow: View {
    let userId: String
    @State private var user = DBUser.placeholder()

    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)

            Text(user.display_name ?? "Unknown Username")
                .font(.headline)
                .foregroundColor(.primary) // Ensures text is visible
        }
        .onAppear {
            Task {
                do {
                    user = try await UserManager.shared.getUser(userId: userId)
                } catch {
                    print("Failed to get User: \(error)")
                }
            }
        }
        .padding(.vertical, 5)
        .contentShape(Rectangle()) // Makes the entire row tappable
    }
}


struct UserSearchView_Previews: PreviewProvider {
    static var previews: some View {
        UserSearchView()
    }
}
