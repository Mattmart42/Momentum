//
//  ActivityManager.swift
//  Momentm_
//
//  Created by matt on 11/6/24.
//

import Foundation
import FirebaseFirestore

final class ActivityManager {
    
    static let shared = ActivityManager()
    private init() { }
    
    private let activityCollection: CollectionReference = Firestore.firestore().collection("activities")
    
    private func activityDocument(activityId: String) -> DocumentReference {
        activityCollection.document(activityId)
    }
    
    func createNewActivity(activity: DBActivity) async throws {
        try activityDocument(activityId: activity.activityId).setData(from: activity, merge: false)
    }
    
    func getActivity(activityId: String) async throws -> DBActivity {
        try await activityDocument(activityId: activityId).getDocument(as: DBActivity.self)
    }
    
    func getUserActivities(userId: String) async throws -> [DBActivity] {
        print("User ID: \(userId)") // Debugging
        let snapshot = try await activityCollection.whereField("user_id", isEqualTo: userId).getDocuments()
        print("Query Snapshot Documents: \(snapshot.documents)") // Debugging
        let activities = snapshot.documents.compactMap { try? $0.data(as: DBActivity.self) }
        print("Parsed Activities: \(activities)") // Debugging
        return activities
    }
    
    func fetchActivities(forUserIds userIds: [String]) async throws -> [DBActivity] {
        guard !userIds.isEmpty else {
            print("No user IDs provided for fetching activities.")
            return []
        }

        var activities: [DBActivity] = []
        let chunkedUserIds = userIds.chunked(into: 10)

        for chunk in chunkedUserIds {
            let chunkActivities: [DBActivity] = try await Firestore.firestore()
                .collection("activities")
                .whereField("user_id", in: chunk)
                .order(by: "date_created", descending: true) // Sort by newest first
                .getDocuments()
                .documents
                .compactMap { try? $0.data(as: DBActivity.self) }

            activities.append(contentsOf: chunkActivities)
        }

        return activities
    }


    


    
    func createActivity(userId: String, title: String?, description: String?, distance: Double, duration: Double, timeOfDay: Date) async throws {
        let activityId = UUID().uuidString
        let data: [String:Any] = [
            DBActivity.CodingKeys.activityId.rawValue : activityId,
            DBActivity.CodingKeys.userId.rawValue : userId,
            DBActivity.CodingKeys.title.rawValue : title ?? "",
            DBActivity.CodingKeys.description.rawValue : description ?? "",
            DBActivity.CodingKeys.distance.rawValue : distance,
            DBActivity.CodingKeys.duration.rawValue : duration,
            DBActivity.CodingKeys.dateCreated.rawValue : timeOfDay,
        ]
        activityCollection.addDocument(data: data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
            }
        }
    }
    
    func updateActivity(activityId: String, userId: String, title: String?, description: String?, distance: Double, duration: Double, timeOfDay: Date) async throws {
        let data: [String:Any] = [
            DBActivity.CodingKeys.userId.rawValue : userId,
            DBActivity.CodingKeys.title.rawValue : title ?? "",
            DBActivity.CodingKeys.description.rawValue : description ?? "",
            DBActivity.CodingKeys.distance.rawValue : distance,
            DBActivity.CodingKeys.duration.rawValue : duration,
            DBActivity.CodingKeys.dateCreated.rawValue : timeOfDay,
        ]
        
        try await activityDocument(activityId: activityId).updateData(data)
    }
    
    func deleteActivity(activityId: String) async throws {
        try await activityDocument(activityId: activityId).delete()
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()

    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
}

// Helper extension to split an array into chunks
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
