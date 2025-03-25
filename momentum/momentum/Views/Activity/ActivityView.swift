//
//  ActivityView.swift
//  Momentm_
//
//  Created by Matthew Martinez on 11/10/24.
//

import SwiftUI
import FirebaseAuth

@MainActor

struct ActivityView: View {
    @EnvironmentObject var appState: AppState
    let userId: String
    
    var title: String
    var description: String
    var dayAndTime = Date()
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dayAndTime)
    }
    var distance: Double
    var duration: Int
    var type: String
    
    @State private var showDetails = false
    @State private var username: String = ""
    @State private var display_name: String = ""
    
    func loadUserData() {
        Task {
            do {
                let user = try await getUser()
                username = user.username ?? "Unknown User"
                display_name = user.display_name ?? "Unknown User"
            } catch {
                username = "Error fetching user"
                display_name = "Error fetching user"
                print("Error loading username: \(error.localizedDescription)")
            }
        }
    }
    
    func getUser() async throws -> DBUser {
        let user = try await UserManager.shared.getUser(userId: userId)
        return user
    }
    
    var body: some View {
        
        
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                NavigationLink(destination: ProfileView(userId: userId, isOwnProfile: userId == Auth.auth().currentUser?.uid)) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    VStack(alignment: .leading) {
                        HStack {
                            Text(display_name)
                                .font(.title3)
                                .fontWeight(.bold)
                            Image(systemName: "figure.run")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .clipShape(Circle())
                        }
                        Text(formattedDate)
                            .font(.subheadline)
                    }
                }
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text(String(title))
                        .font(.title)
                        .fontWeight(.bold)
                    Text(String(description))
                }
                Spacer()
            }
            .padding(.vertical, 5)
            
            // Activity summary section
            HStack {
                HStack {
                    VStack {
                        Text("Distance")
                            .font(.subheadline)
                        Text(String(distance)).fontWeight(.bold)
                    }
                    VStack {
                        Text("Pace")
                            .font(.subheadline)
                        Text(calculatePace(seconds: duration, distance: distance))
                            .fontWeight(.bold)
                    }
                    VStack {
                        Text("Time")
                            .font(.subheadline)
                        Text(formatDuration(seconds: duration))
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.vertical, 5)
            
            // Optional Map Preview (Mocked as Rectangle for now)
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 100)
                .cornerRadius(10)
                .padding(.vertical, 5)
            
            // Expandable Details
            if showDetails {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Calories:")
                        //Text(calories).fontWeight(.bold)
                    }
                    HStack {
                        Text("Elevation Gain:")
                        //Text(elevation).fontWeight(.bold)
                    }
                }
                .transition(.opacity)  // Fade in animation
            }
            
            // Actions Row
            HStack {
                Button(action: { /* Like Action */ }) {
                    Image(systemName: "heart")
                }
                Button(action: { /* Comment Action */ }) {
                    Image(systemName: "message")
                }
                Spacer()
                Button(action: { withAnimation { showDetails.toggle() } }) {
                    Text(showDetails ? "Hide Details" : "Show Details")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 5)
            
        }
        .padding()
        .background(Color.black)
        .foregroundColor(Color.white)
        .cornerRadius(10)
//        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
//        .padding(.horizontal)
        .onAppear {
            loadUserData()
        }
    }
    
    func calculatePace(seconds: Int, distance: Double) -> String {
        guard distance > 0 else { return "Invalid distance" }
        let pace = Double(seconds) / distance
        return formatDuration(seconds: Int(pace))
    }
    
    func formatDuration(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(remainingSeconds)s"
        } else {
            return "\(remainingSeconds)s"
        }
    }
    
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(
            userId: "VHAJFyMG1fgNhn65RuPG20FHkXA2",
            title: "Morning Run",
            description: "Good run today",
            dayAndTime: Date(),
            distance: 5.2,
            duration: 45,
            type: "Run"
        )
    }
}
