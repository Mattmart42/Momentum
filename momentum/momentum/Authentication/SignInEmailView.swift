
//
//  SignInEmailView.swift
//  Momentm_
//
//  Created by martel on 11/18/24.
//

//import SwiftUI
//
//struct SignInEmailView: View {
//    
//    @StateObject private var viewModel = SignInEmailViewModel()
//    @Binding var showSignInView: Bool
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                Text("Sign in with an existing account or sign up below.")
//                    .font(.title)
//                TextField("Email...", text: $viewModel.email)
//                    .padding()
//                    .background(Color.gray.opacity(0.4))
//                    .cornerRadius(10)
//                
//                SecureField("Password...", text: $viewModel.password)
//                    .padding()
//                    .background(Color.gray.opacity(0.4))
//                    .cornerRadius(10)
//                
//                Button {
//                    Task {
//                        do {
//                            try await viewModel.signIn()
//                            showSignInView = false
//                            return
//                        } catch {
//                            print(error)
//                        }
//                    }
//                } label: {
//                    Text("Sign In")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(height: 55)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                }
//                
//                NavigationLink(destination: CreateAccountView(showSignInView: $showSignInView))
//                {
//                    Text("Sign Up")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(height: 55)
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                }
//                .padding()
//                .navigationTitle("Momentm")
//                .navigationBarTitleDisplayMode(.inline)
//            }
//        }
//    }
//}
//
//struct SignInEmailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            SignInEmailView(showSignInView: .constant(false))
//        }
//    }
//}

