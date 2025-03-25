//
//  UserManager.swift
//  Momentm_
//
//  Created by matt on 10/11/24 with help from tutorials by Swiftful Thinking.
//

import Foundation
import Firebase
import FirebaseFirestore

final class UserManager {
    
    let db = Firestore.firestore()
    static let shared = UserManager()
    private let usersCollection = "users"
    private let followersCollection = "followers"
    private let followingsCollection = "followings"
    
    @Published var searchResults = [DBUser]()
    
    private init() { }
    
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    func updateUserData(userId: String, display_name: String?, bio: String?, city: String?, birthday: Date?, gender: String?, weight: String?, height: String?) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.username.rawValue : display_name?.lowercased() ?? "",
            DBUser.CodingKeys.display_name.rawValue : display_name ?? "",
            DBUser.CodingKeys.bio.rawValue : bio ?? "",
            DBUser.CodingKeys.city.rawValue : city ?? "",
            DBUser.CodingKeys.birthday.rawValue : birthday,
            DBUser.CodingKeys.gender.rawValue : gender ?? "",
            DBUser.CodingKeys.weight.rawValue : weight ?? "",
            DBUser.CodingKeys.height.rawValue : height ?? "",
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func followUser(userId: String, targetUserId: String) async throws {
        print("User Followed")
        let currentUserRef = db.collection(usersCollection).document(userId)
        let targetUserRef = db.collection(usersCollection).document(targetUserId)
        
        try await currentUserRef.collection(followingsCollection).document(targetUserId).setData([:])
        try await targetUserRef.collection(followersCollection).document(userId).setData([:])
    }
    
    func unfollowUser(userId: String, targetUserId: String) async throws {
        print("User Unfollowed")
        let currentUserRef = db.collection(usersCollection).document(userId)
        let targetUserRef = db.collection(usersCollection).document(targetUserId)
        
        try await currentUserRef.collection(followingsCollection).document(targetUserId).delete()
        try await targetUserRef.collection(followersCollection).document(userId).delete()
    }
    
    func fetchFollowingIds(userId: String) async throws -> [String] {
        // Reference to the user's followings sub-collection
        let followingsRef = db.collection(usersCollection).document(userId).collection(followingsCollection)

        // Fetch the followings
        do {
            // Fetch the documents in the followings sub-collection
            let querySnapshot = try await followingsRef.getDocuments()
            
            // Extract the document IDs, which correspond to the user IDs
            let followingIds: [String] = querySnapshot.documents.map { $0.documentID }
            
            print("Following IDs: \(followingIds)")
            return followingIds
        } catch {
            print("Error fetching followings: \(error)")
            return []
        }
    }
    
    func fetchFollowerIds(userId: String) async throws -> [String] {
        // Reference to the user's followings sub-collection
        let followersRef = db.collection(usersCollection).document(userId).collection(followersCollection)

        // Fetch the followings
        do {
            // Fetch the documents in the followings sub-collection
            let querySnapshot = try await followersRef.getDocuments()
            
            // Extract the document IDs, which correspond to the user IDs
            let followerIds: [String] = querySnapshot.documents.map { $0.documentID }
            
            print("Follower IDs: \(followerIds)")
            return followerIds
        } catch {
            print("Error fetching followers: \(error)")
            return []
        }
    }

    
    func getFollowing(userId: String) async throws -> [String] {
        let following: [String] = try await db
            .collection("users")
            .document(userId)
            .collection("following")
            .getDocuments()
            .documents
            .compactMap { $0["userId"] as? String }
        return following
    }
    
    func isFollowing(userId: String, targetUserId: String) async throws -> Bool {
        let followingRef = db.collection(usersCollection).document(userId).collection(followingsCollection).document(targetUserId)
        return try await followingRef.getDocument().exists ? true : false
    }
    
    func searchUsers(by username: String) {
        guard !username.isEmpty else {
            self.searchResults = []
            return
        }
        
        let searchText = username.lowercased()
        
        userCollection
            .whereField("username", isGreaterThanOrEqualTo: searchText)
            .whereField("username", isLessThanOrEqualTo: searchText + "\u{f8ff}")
            .getDocuments() {(snapshot, error) in
                if let error = error {
                    print("Error searching for users: \(error)")
                    self.searchResults = []
                    return
                }
                
                self.searchResults = snapshot?.documents.compactMap { document in
                    try? document.data(as: DBUser.self)
                } ?? []
            }
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()

    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    private var userActivities: ListenerRegistration? = nil
    
    
    
    func updateUserPremiumStatus(userId: String, isPremium: Bool) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.isPremium.rawValue : isPremium,
        ]

        try await userDocument(userId: userId).updateData(data)
    }
    
    func addUserPreference(userId: String, preference: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayUnion([preference])
        ]

        try await userDocument(userId: userId).updateData(data)
    }

    func removeUserPreference(userId: String, preference: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayRemove([preference])
        ]

        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateUserProfileImagePath(userId: String, path: String?, url: String?) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.profileImagePath.rawValue : path,
            DBUser.CodingKeys.profileImagePathUrl.rawValue : url,
        ]

        try await userDocument(userId: userId).updateData(data)
    }
    
    func fetchUserData(userId: String) async throws -> DBUser? {
        let document = try await userDocument(userId: userId).getDocument()
        return try document.data(as: DBUser.self)
    }
}

import Combine

struct UserFavoriteProduct: Codable {
    let id: String
    let productId: Int
    let dateCreated: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case productId = "product_id"
        case dateCreated = "date_created"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.productId = try container.decode(Int.self, forKey: .productId)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.productId, forKey: .productId)
        try container.encode(self.dateCreated, forKey: .dateCreated)
    }
    
}
