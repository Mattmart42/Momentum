//
//  SpotifyModels.swift
//  Momentm_
//
//  Created by Eric Hwang on 11/1/24.
//
import Foundation

// Model for user profile data
struct UserProfile: Codable {
    let displayName: String
    let followers: Int
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case followers
    }
    
    enum FollowersKeys: String, CodingKey {
        case total
    }
    
    // Custom decoding to handle nested JSON structure for followers count
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displayName = try container.decode(String.self, forKey: .displayName)
        
        let followersContainer = try container.nestedContainer(keyedBy: FollowersKeys.self, forKey: .followers)
        followers = try followersContainer.decode(Int.self, forKey: .total)
    }
}

// Model for a single track in recommendations
struct Track: Codable {
    let id: String
    let name: String
    let artistName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case artists
    }
    
    // Custom decoding to get the first artist's name
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        var artistsContainer = try container.nestedUnkeyedContainer(forKey: .artists)
        let firstArtist = try artistsContainer.nestedContainer(keyedBy: CodingKeys.self)
        artistName = try firstArtist.decode(String.self, forKey: .name)
    }
    
    // Custom encoding to conform to Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        
        var artistsContainer = container.nestedUnkeyedContainer(forKey: .artists)
        var firstArtist = artistsContainer.nestedContainer(keyedBy: CodingKeys.self)
        try firstArtist.encode(artistName, forKey: .name)
    }
}

// Model for recommendations response
struct Recommendations: Codable {
    let tracks: [Track]
}
