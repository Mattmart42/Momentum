//
//  AuthenticationView.swift
//  Momentm_
//
//  Created by matt on 10/11/24 with help from tutorials by Swiftful Thinking.
//

import SwiftUI
//import GoogleSignIn
//import GoogleSignInSwift

struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            NavigationLink {
                //SignInEmailView(showSignInView: $showSignInView)
                SignInView()
            } label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
//            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
//                Task {
//                    do {
//                        try await viewModel.signInGoogle()
//                        showSignInView = false
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//            
//            Button(action: {
//                Task {
//                    do {
//                        try await viewModel.signInApple()
//                        showSignInView = false
//                    } catch {
//                        print(error)
//                    }
//                }
//            }, label: {
//                SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
//                    .allowsHitTesting(false)
//            })
//            .frame(height: 55)


            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(showSignInView: .constant(false))
        }
    }
}
