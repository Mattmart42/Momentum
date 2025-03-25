//
//  SpotifyAuthManager.swift
//  Momentm_
//
//  Created by Eric Hwang on 11/1/24.
//
//import Foundation
//import Combine
//#if canImport(UIKit)
//import UIKit
//#elseif canImport(AppKit)
//import AppKit
//#endif
//import SwiftUI
//import KeychainAccess
//
//class SpotifyAuthManager: ObservableObject {
//    static let shared = SpotifyAuthManager()
//    private init() {}
//    
//    private let clientId = "09a61d969ef443d5874b4c811b2ec686"
//    private let redirectUri = "momentmspotify://callback"
//    private let scopes = "user-read-private user-top-read user-library-read"
//    
//    @Published var isLoggedIn = false
//    @Published var userProfile: UserProfile?
//    @Published var recommendations: [Track]?
//    
//    private let keychain = Keychain(service: "com.MEM.Momentm")
//    
//    private var accessToken: String? {
//        get {
//            let token = try? keychain.get("accessToken")
//            return token
//        }
//        set {
//            if let token = newValue {
//                try? keychain.set(token, key: "accessToken")
//            } else {
//                try? keychain.remove("accessToken")
//            }
//        }
//    }
//    
//    func startAuthentication() {
//        let encodedRedirectUri = redirectUri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//        let encodedScopes = scopes.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//        
//        print("Encoded Redirect URI: \(encodedRedirectUri ?? "Encoding failed")")
//        print("Encoded Scopes: \(encodedScopes ?? "Encoding failed")")
//        
//        let authUrl = "https://accounts.spotify.com/authorize?client_id=\(clientId)&response_type=code&redirect_uri=\(encodedRedirectUri!)&scope=\(encodedScopes!)"
//        
//        print("Authentication URL: \(authUrl)")
//
//        if let url = URL(string: authUrl) {
//            #if canImport(UIKit)
//            UIApplication.shared.open(url)
//            #elseif canImport(AppKit)
//            NSWorkspace.shared.open(url)
//            #endif
//        }
//    }
//    
//    func handleCallback(url: URL) {
//        print("Handling callback URL: \(url)")
//        guard let code = extractCode(from: url) else {
//            print("No code found in callback URL.")
//            return
//        }
//        print("Extracted code: \(code)")
//        fetchAccessToken(using: code)
//    }
//    
//    private func fetchAccessToken(using code: String) {
//        let url = URL(string: "https://accounts.spotify.com/api/token")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//        let bodyParams = [
//            "grant_type": "authorization_code",
//            "code": code,
//            "redirect_uri": redirectUri,
//            "client_id": clientId,
//            "client_secret": "d121b31ab4d944598ed926724e653b80"
//        ]
//
//        request.httpBody = bodyParams
//            .map { "\($0)=\($1)" }
//            .joined(separator: "&")
//            .data(using: .utf8)
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error fetching access token: \(error.localizedDescription)")
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("No HTTP response.")
//                return
//            }
//            
//            print("HTTP Status Code for token request: \(httpResponse.statusCode)")
//                    if let data = data {
//                        print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
//                    } else {
//                        print("No data returned from token request.")
//                    }
//            
//            guard let data = data else {
//                print("No data returned from token request.")
//                return
//            }
//
//            if httpResponse.statusCode != 200 {
//                let responseString = String(data: data, encoding: .utf8) ?? "No response body"
//                print("Non-200 response: \(responseString)")
//                return
//            }
//
//            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                print("Token response JSON: \(json)")
//                if let token = json["access_token"] as? String {
//                    DispatchQueue.main.async {
//                        self.accessToken = token
//                        self.isLoggedIn = true
//                        self.fetchUserProfile()
//                        self.fetchRecommendations()
//                    }
//                } else {
//                    print("access_token not found in the response.")
//                }
//            } else {
//                print("Failed to parse JSON for token response.")
//            }
//        }.resume()
//    }
//    
//    func fetchUserProfile() {
//        guard let token = accessToken else { return }
//        let url = URL(string: "https://api.spotify.com/v1/me")!
//        var request = URLRequest(url: url)
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data else { return }
//            let userProfile = try? JSONDecoder().decode(UserProfile.self, from: data)
//            DispatchQueue.main.async {
//                self.userProfile = userProfile
//            }
//        }.resume()
//    }
//    
//    func fetchRecommendations() {
//        guard let token = accessToken else { return }
//        let url = URL(string: "https://api.spotify.com/v1/recommendations?seed_genres=pop")!
//        var request = URLRequest(url: url)
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data else { return }
//            let recommendationData = try? JSONDecoder().decode(Recommendations.self, from: data)
//            DispatchQueue.main.async {
//                self.recommendations = recommendationData?.tracks
//            }
//        }.resume()
//    }
//    
//    private func extractCode(from url: URL) -> String? {
//        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
//        return components?.queryItems?.first(where: { $0.name == "code" })?.value
//    }
//    
//    func validateAccessToken(completion: @escaping (Bool) -> Void = { _ in }) {
//        guard let token = accessToken else {
//            DispatchQueue.main.async {
//                self.isLoggedIn = false
//                completion(false)
//            }
//            return
//        }
//
//        let url = URL(string: "https://api.spotify.com/v1/me")!
//        var request = URLRequest(url: url)
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//        URLSession.shared.dataTask(with: request) { _, response, error in
//            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                DispatchQueue.main.async {
//                    self.isLoggedIn = true
//                    print("Token is valid. User is logged in.")
//                    completion(true)
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.isLoggedIn = false
//                    print("Token is invalid. User is not logged in.")
//                    completion(false)
//                }
//            }
//        }.resume()
//    }
//}
