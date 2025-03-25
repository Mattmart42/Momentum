import SwiftUI
import FirebaseAuth
import _PhotosUI_SwiftUI

struct ProfileView: View {
    
    @State private var showingEditProfile = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var url: URL? = nil
    @State private var isFollowing = false
    @StateObject private var viewModel = ProfileViewModel()
    
    let userId: String
    var authUserId: String? { Auth.auth().currentUser?.uid }
    let isOwnProfile: Bool

    @State private var username = ""
    @State private var city = ""
    @State private var bio = ""
    
    @State private var followerCount = 0
    @State private var followingCount = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Button(action: {
                            if !isOwnProfile {
                                print("Edit Profile Picture")
                            }
                        }) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        }
                        .disabled(!isOwnProfile)

                        VStack(alignment: .leading, spacing: 10) {
                            Text(username)
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Text(city)
                                .font(.body)

                            Text(bio)
                                .font(.body)
                        }
                        .padding(.leading, 10)

                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.black))
                    .cornerRadius(10)
                    .foregroundColor(.white)

                    HStack {
                        FollowersSectionView(followerCount: followerCount, followingCount: followingCount, userId: userId)
                        
                        Spacer()
                        
                        if !isOwnProfile {
                            Button(action: {
                                Task {
                                    do {
                                        if isFollowing {
                                            try await UserManager.shared.unfollowUser(userId: authUserId!, targetUserId: userId)
                                        } else {
                                            try await UserManager.shared.followUser(userId: authUserId!, targetUserId: userId)
                                        }
                                        isFollowing.toggle()
                                    } catch {
                                        print("Failed to update follow state: \(error)")
                                    }
                                }
                            }) {
                                Text(isFollowing ? "Unfollow" : "Follow")
                                    .font(.headline)
                                    .foregroundColor(isFollowing ? Color.white : Color.black)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(isFollowing ? Color.black : Color.white)
                                            .stroke(isFollowing ? Color.white : Color.black, lineWidth: 2)
                                    )
                                    .cornerRadius(10)
                            }
                        }
                    }

                    HStack {
                        Text("This Week:")
                            .font(.headline)
                        Text("30 miles")
                            .font(.headline)
                        Text("5hr 41min")
                            .font(.headline)
                    }
                    .padding(.horizontal)

                    ActivityScrollView(userIds: [userId])

                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isOwnProfile {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showingEditProfile.toggle()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 30, height: 30)
                                Image(systemName: "pencil")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView(showSignInView: .constant(false))) {
                            ZStack {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 30, height: 30)
                                Image(systemName: "gearshape")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
        }
        .onAppear {
            loadProfileData(userId: userId)
        }

    }
    
    private func loadProfileData(userId: String) {
        Task {
            await fetchUserDetails(for: userId)
            await checkFollowingStatus(for: userId)
            do {
                followingCount = try await UserManager.shared.fetchFollowingIds(userId: userId).count
                followerCount = try await UserManager.shared.fetchFollowerIds(userId: userId).count
            } catch {
                print("Failed to get following/er counts: \(error)")
            }
            
        }
    }

    private func fetchUserDetails(for userId: String) async {
        do {
            let fetchedUser = try await UserManager.shared.getUser(userId: userId)
            username = fetchedUser.display_name ?? "Username"
            city = fetchedUser.city ?? "City"
            bio = fetchedUser.bio ?? "No bio available"
        } catch {
            print("Failed to fetch user details: \(error)")
        }
    }

    private func checkFollowingStatus(for userId: String) async {
        guard let authUserId = authUserId else {
            print("Error: authUserId is nil. Cannot check follow status.")
            return
        }
        
        if userId != authUserId {
            do {
                isFollowing = try await UserManager.shared.isFollowing(userId: authUserId, targetUserId: userId)
            } catch {
                print("Failed to check follow status: \(error)")
            }
        }
    }

}

struct FollowersSectionView: View {
    let followerCount: Int
    let followingCount: Int
    let userId: String

    var body: some View {
        HStack {
            NavigationLink(destination: FollowersView(userId: userId)) {
                VStack {
                    Text("Followers")
                        .font(.headline)
                    Text("\(followerCount)")
                        .font(.subheadline)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
                .cornerRadius(10)
                .foregroundColor(.black)
            }

            NavigationLink(destination: FollowingView(userId: userId)) {
                VStack {
                    Text("Following")
                        .font(.headline)
                    Text("\(followingCount)")
                        .font(.subheadline)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
                .cornerRadius(10)
                .foregroundColor(.black)
            }

            Spacer()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userId: "VHAJFyMG1fgNhn65RuPG20FHkXA2", isOwnProfile: true)
    }
}
