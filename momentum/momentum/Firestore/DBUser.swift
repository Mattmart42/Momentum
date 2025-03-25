//
//  DBUser.swift
//  Momentm_
//
//  Created by Matthew Martinez on 11/14/24.
//

import Foundation

struct DBUser: Codable {
    let userId: String
    let email: String?
    let dateCreated: Date?
    
    let photoUrl: String?
    let username: String?
    let display_name: String?
    let bio: String?
    let city: String?
    let birthday: Date?
    let gender: String?
    let weight: String?
    let height: String?
    
    let isPremium: Bool?
    let preferences: [String]?
    let profileImagePath: String?
    let profileImagePathUrl: String?
    
    let followings: [String]?
    let followers: [String]?

    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.dateCreated = Date()
        
        self.photoUrl = auth.photoUrl
        self.username = String()
        self.display_name = String()
        self.bio = String()
        self.city = String()
        self.birthday = Date()
        self.gender = String()
        self.weight = String()
        self.height = String()
        
        self.isPremium = false
        self.preferences = nil
        self.profileImagePath = nil
        self.profileImagePathUrl = nil
        
        self.followings = nil
        self.followers = nil
    }
    
    init(
        userId: String,
        email: String? = nil,
        dateCreated: Date? = nil,
        
        photoUrl: String? = nil,
        username: String? = nil,
        display_name: String? = nil,
        bio: String? = nil,
        city: String? = nil,
        birthday: Date? = nil,
        gender: String? = nil,
        weight: String? = nil,
        height: String? = nil,
        
        isPremium: Bool? = nil,
        preferences: [String]? = nil,
        profileImagePath: String? = nil,
        profileImagePathUrl: String? = nil,
        
        followings: [String]? = nil,
        followers: [String]? = nil
    ) {
        self.userId = userId
        self.email = email
        self.dateCreated = dateCreated
        
        self.photoUrl = photoUrl
        self.username = username
        self.display_name = display_name
        self.bio = bio
        self.city = city
        self.birthday = birthday
        self.gender = gender
        self.weight = weight
        self.height = height
        
        self.isPremium = isPremium
        self.preferences = preferences
        self.profileImagePath = profileImagePath
        self.profileImagePathUrl = profileImagePathUrl
        
        self.followings = followings
        self.followers = followers
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case dateCreated = "date_created"
        
        case photoUrl = "photo_url"
        case username = "username"
        case display_name = "display_name"
        case bio = "bio"
        case city = "city"
        case birthday = "birthday"
        case gender = "gender"
        case weight = "weight"
        case height = "height"
        
        case isPremium = "user_isPremium"
        case preferences = "preferences"
        case profileImagePath = "profile_image_path"
        case profileImagePathUrl = "profile_image_path_url"
        
        case followings = "followings"
        case followers = "followers"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.display_name = try container.decodeIfPresent(String.self, forKey: .display_name)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        self.birthday = try container.decodeIfPresent(Date.self, forKey: .birthday)
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.weight = try container.decodeIfPresent(String.self, forKey: .weight)
        self.height = try container.decodeIfPresent(String.self, forKey: .height)
        
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
        self.preferences = try container.decodeIfPresent([String].self, forKey: .preferences)
        self.profileImagePath = try container.decodeIfPresent(String.self, forKey: .profileImagePath)
        self.profileImagePathUrl = try container.decodeIfPresent(String.self, forKey: .profileImagePathUrl)
        
        self.followings = try container.decodeIfPresent([String].self, forKey: .followings)
        self.followers = try container.decodeIfPresent([String].self, forKey: .followers)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.username, forKey: .username)
        try container.encodeIfPresent(self.display_name, forKey: .display_name)
        try container.encodeIfPresent(self.bio, forKey: .bio)
        try container.encodeIfPresent(self.city, forKey: .city)
        try container.encodeIfPresent(self.birthday, forKey: .birthday)
        try container.encodeIfPresent(self.gender, forKey: .gender)
        try container.encodeIfPresent(self.weight, forKey: .weight)
        try container.encodeIfPresent(self.height, forKey: .height)
        
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
        try container.encodeIfPresent(self.preferences, forKey: .preferences)
        try container.encodeIfPresent(self.profileImagePath, forKey: .profileImagePath)
        try container.encodeIfPresent(self.profileImagePathUrl, forKey: .profileImagePathUrl)
        
        try container.encodeIfPresent(self.followings, forKey: .followings)
        try container.encodeIfPresent(self.followers, forKey: .followers)
    }
    
}

extension DBUser {
    static func placeholder() -> DBUser {
        DBUser(
            userId: "placeholder",
            email: nil,
            dateCreated: Date(),
            photoUrl: nil,
            username: "Placeholder",
            display_name: "Placeholder User",
            bio: "This is a placeholder bio.",
            city: "Placeholder City",
            birthday: nil,
            gender: nil,
            weight: nil,
            height: nil,
            isPremium: false,
            preferences: nil,
            profileImagePath: nil,
            profileImagePathUrl: nil,
            followings: nil,
            followers: nil
        )
    }
}

