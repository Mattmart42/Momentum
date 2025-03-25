//
//  spotifyView.swift
//  Momentm_
//
//  Created by Eric Hwang on 11/1/24.
//

//import SwiftUI
//import WebKit
//import SafariServices
//import Combine
//
//struct SpotifyView: View {
//    @ObservedObject var spotifyAuth = SpotifyAuthManager.shared
//    
//    var body: some View {
//        VStack {
//            if spotifyAuth.isLoggedIn {
//                // Display profile information if logged in
//                if let userProfile = spotifyAuth.userProfile {
//                    Text("Welcome, \(userProfile.displayName)")
//                        .font(.title)
//                    Text("Followers: \(userProfile.followers)")
//                        .font(.subheadline)
//                } else {
//                    Text("Loading profile...")
//                        .foregroundColor(.gray)
//                }
//                
//                // Display recommended tracks if available
//                if let recommendations = spotifyAuth.recommendations, !recommendations.isEmpty {
//                    List(recommendations, id: \.id) { track in
//                        VStack(alignment: .leading) {
//                            Text(track.name)
//                                .font(.headline)
//                            Text("by \(track.artistName)")
//                                .font(.subheadline)
//                        }
//                    }
//                } else {
//                    Text("Loading recommendations...")
//                        .foregroundColor(.gray)
//                    Text("Unfortunately the recommendations will never load :(")
//                        .foregroundColor(.gray)
//                    Text("Spotify recently removed this functionality from their Web API service")
//                        .foregroundColor(.gray)
//                    Link("Check out the announcement", destination: URL(string: "https://developer.spotify.com/blog/2024-11-27-changes-to-the-web-api")!)
//                        .font(.title2)
//                        .foregroundColor(.blue)
//                }
//            } else {
//                // Display login prompt if not logged in
//                Button("Log in with Spotify") {
//                    spotifyAuth.startAuthentication()
//                }
//                .font(.title)
//                .padding()
//            }
//        }
//        .onAppear {
//            // Validate token and fetch data if already logged in
//            spotifyAuth.validateAccessToken { isValid in
//                if isValid {
//                    spotifyAuth.fetchUserProfile()
//                    spotifyAuth.fetchRecommendations()
//                }
//            }
//        }
//        .onOpenURL { url in
//            print("onOpenURL triggered with: \(url.absoluteString)")
//            SpotifyAuthManager.shared.handleCallback(url: url)
//        }
//        .padding()
//    }
//}
