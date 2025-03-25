//
//  ActivityScrollView.swift
//  Momentm_
//
//  Created by Matthew Martinez on 11/10/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

@MainActor
final class ActivityScrollViewModel: ObservableObject {
    @Published var activities: [DBActivity] = []

    func fetchActivities(for userIds: [String]) async throws {
        self.activities = try await ActivityManager.shared.fetchActivities(forUserIds: userIds)
    }
}

struct ActivityScrollView: View {
    @State private var showingLogActivity = false
    @StateObject private var viewModel = ActivityScrollViewModel()
    @State private var activities: [DBActivity] = []
    //let user: DBUser
    
    let userIds: [String]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
//                ForEach(activities, id: \.activityId) { activity in
//                    ActivityView(
//                        title: activity.title ?? "Momentous Run", description: activity.description ?? "", dayAndTime: activity.dateCreated, distance: activity.distance, duration: activity.duration, type: "run"
//                    )
//                }
                if viewModel.activities.isEmpty {
                    Text("No activities to show")
                        .font(.headline)
                        .foregroundColor(.gray)
                } else {
                    ForEach(viewModel.activities, id: \.activityId) { activity in
                        ActivityView(userId: activity.userId, title: activity.title ?? "Momentous Run", description: activity.description ?? "", dayAndTime: activity.dateCreated, distance: activity.distance, duration: activity.duration, type: "run")
                    }
                }
            }
            .padding()
        }
        .onAppear {
            loadActivities()
        }
//        .onAppear {
//            Task {
//                do {
//                    activities = try await ActivityManager.shared.getUserActivities(userId: user.userId)
//                } catch {
//                    print("Failed to load activities: \(error)")
//                }
//            }
//        }
    }
    
    private func loadActivities() {
        Task {
            do {
                try await viewModel.fetchActivities(for: userIds)
            } catch {
                print("Failed to fetch activities: \(error)")
            }
        }
    }
}

struct ActivityScrollView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityScrollView(userIds: ["VHAJFyMG1fgNhn65RuPG20FHkXA2"])
    }
}
