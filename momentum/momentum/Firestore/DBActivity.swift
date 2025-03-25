//
//  DBActivity.swift
//  Momentm_
//
//  Created by Matthew Martinez on 11/15/24.
//

import Foundation
import FirebaseCore

struct DBActivity: Codable {
    let activityId: String
    let userId: String
    let dateCreated: Date
    
    let photoUrl: String?
    let title: String?
    let description: String?
    
    let activityType: String?
    let distance: Double
    let duration: Int
    
    let profileImagePath: String?
    let profileImagePathUrl: String?

    init(auth: AuthDataResultModel) {
        self.activityId = String()
        self.userId = auth.uid
        self.dateCreated = Date()
        
        self.photoUrl = auth.photoUrl
        self.title = String()
        self.description = String()
        
        self.activityType = String()
        self.distance = Double()
        self.duration = Int()
        
        self.profileImagePath = nil
        self.profileImagePathUrl = nil
    }
    
    init(
        activityId: String,
        userId: String,
        dateCreated: Date,
        
        photoUrl: String? = nil,
        title: String? = nil,
        description: String? = nil,
        
        activityType: String? = nil,
        distance: Double,
        duration: Int,
        
        profileImagePath: String? = nil,
        profileImagePathUrl: String? = nil
    ) {
        self.activityId = activityId
        self.userId = userId
        self.dateCreated = dateCreated
        
        self.photoUrl = photoUrl
        self.title = title
        self.description = description
        
        self.activityType = activityType
        self.distance = distance
        self.duration = duration
        
        self.profileImagePath = profileImagePath
        self.profileImagePathUrl = profileImagePathUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case activityId = "activity_id"
        case userId = "user_id"
        case dateCreated = "date_created"
        
        case photoUrl = "photo_url"
        case title = "title"
        case description = "description"
        
        case activityType = "activityType"
        case distance = "distance"
        case duration = "duration"
        
        case profileImagePath = "profile_image_path"
        case profileImagePathUrl = "profile_image_path_url"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.activityId = try container.decode(String.self, forKey: .activityId)
        self.userId = try container.decode(String.self, forKey: .userId)
        if let timestamp = try? container.decode(Timestamp.self, forKey: .dateCreated) {
            self.dateCreated = timestamp.dateValue()
        } else {
            self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        }
        
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        
        self.activityType = try container.decodeIfPresent(String.self, forKey: .activityType)
        self.distance = try container.decodeIfPresent(Double.self, forKey: .distance) ?? {
            throw NSError(domain: "DBActivityError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Distance is required."])
        }()
        self.duration = try container.decodeIfPresent(Int.self, forKey: .duration) ?? {
            throw NSError(domain: "DBActivityError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Duration is required."])
        }()
        
        self.profileImagePath = try container.decodeIfPresent(String.self, forKey: .profileImagePath)
        self.profileImagePathUrl = try container.decodeIfPresent(String.self, forKey: .profileImagePathUrl)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.activityId, forKey: .activityId)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.title, forKey: .title)
        try container.encodeIfPresent(self.description, forKey: .description)
        
        try container.encodeIfPresent(self.activityType, forKey: .activityType)
        try container.encodeIfPresent(self.distance, forKey: .distance)
        try container.encodeIfPresent(self.duration, forKey: .duration)
        
        try container.encodeIfPresent(self.profileImagePath, forKey: .profileImagePath)
        try container.encodeIfPresent(self.profileImagePathUrl, forKey: .profileImagePathUrl)
    }
    
}
