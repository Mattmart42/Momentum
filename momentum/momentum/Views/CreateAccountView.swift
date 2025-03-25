//
//  CreateAccountView.swift
//  Momentm
//
//  Created by martel on 11/18/24.
//
//import SwiftUI
//import FirebaseAuth
//
//struct CreateAccountView: View {
//    
////    @State private var email: String = ""
////    @State private var username: String = ""
////    @State private var password: String = ""
////    @State private var birthday = Date()
//    @State private var height: String = ""
//    @State private var gender: String = ""
//    @State private var errorMessage: String = ""
//    
//    @State private var showingGenderPicker = false
//    
//    @State private var userIsLoggedIn = false
//    @Binding var showSignInView: Bool
//    
//    @StateObject private var viewModel = SignInEmailViewModel()
//    
//    var body: some View {
//        if userIsLoggedIn {
//            RootView()
//        } else {
//            content
//        }
//    }
//    
//    var content: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                Text("Momentm")
//                    .font(.largeTitle)
//                    .bold()
//                
////                Button(action: {
////                    // Placeholder for future profile photo action
////                }) {
////                    Text("+ Add Photo")
////                        .foregroundColor(.blue)
////                        .padding()
////                        .overlay(
////                            RoundedRectangle(cornerRadius: 10)
////                                .stroke(Color.blue, lineWidth: 2)
////                        )
////                }
//                
//                    TextField("Name", text: $viewModel.username)
//                        .padding()
//                        .background(Color.gray.opacity(0.4))
//                        .cornerRadius(10)
//                    
//                    TextField("Email", text: $viewModel.email)
//                        .padding()
//                        .background(Color.gray.opacity(0.4))
//                        .cornerRadius(10)
//                        .keyboardType(.emailAddress)
//                        .autocapitalization(.none)
//                    
//                    SecureField("Password", text: $viewModel.password)
//                        .padding()
//                        .background(Color.gray.opacity(0.4))
//                        .cornerRadius(10)
//                    
//                    HStack {
//                        Text("Birthday")
//                        DatePicker("Birthday", selection: $viewModel.birthday, in: ...Date(), displayedComponents: [.date])
//                            .datePickerStyle(DefaultDatePickerStyle())
//                            .labelsHidden()
//                            .frame(maxWidth: .infinity, alignment: .trailing)
//                    }
//                    .padding()
//                    .background(Color.gray.opacity(0.4))
//                    .cornerRadius(8)
//                    
//                    
//                    Button(action: {
//                        showingGenderPicker.toggle()
//                    }) {
//                        HStack {
//                            Text("Gender \(gender.isEmpty ? "Select" : gender)")
//                                .foregroundColor(.primary)
//                            Spacer()
//                        }
//                        .padding()
//                        .background(Color.gray.opacity(0.4))
//                        .cornerRadius(8)
//                    }
//                
//                
//                if !errorMessage.isEmpty {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                        .padding()
//                }
//                
//                Button("Create Account") {
//                    Task {
//                        do {
//                            viewModel.gender = gender
//                            try await viewModel.signUp()
//                            showSignInView = false
//                            return
//                        } catch {
//                            print(error)
//                        }
//                    }
//                }
//                .font(.headline)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//                
//                Spacer()
//            }
//            .padding()
//            .sheet(isPresented: $showingGenderPicker) {
//                GenderPicker(gender: $viewModel.gender)
//            }
//        }
//    }
//    
//    func signUp(email: String, password: String) {
//        Auth.auth().createUser(withEmail: email, password: password) { result, error in
//            if let error = error {
//                self.errorMessage = error.localizedDescription
//            } else {
//                self.errorMessage = ""
//                print("User created successfully with email: \(email)")
//            }
//        }
//    }
//    
////    func validateInputs() -> Bool {
////        if $viewModel.email.isEmpty || $viewModel.password.isEmpty || $viewModel.username.isEmpty || $viewModel.gender.isEmpty {
////            errorMessage = "Please fill out all fields."
////            return false
////        }
////        if password.count < 6 {
////            errorMessage = "Password must be at least 6 characters."
////            return false
////        }
////        return true
////    }
//}
//
//struct CreateAccountView_Previews: PreviewProvider {
//    @State static var showSignInView = true
//    
//    static var previews: some View {
//        CreateAccountView(showSignInView: $showSignInView)
//    }
//}

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateAccountView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var birthday = Date()
    @State private var gender = ""
    
    @State private var showingGenderPicker = false

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)

            TextField("Username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)

            HStack {
                Text("Birthday")
                DatePicker("Birthday", selection: $birthday, in: ...Date(), displayedComponents: [.date])
                    .datePickerStyle(DefaultDatePickerStyle())
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(8)

            Button(action: {
                showingGenderPicker.toggle()
            }) {
                HStack {
                    Text("Gender \(gender.isEmpty ? "Select" : gender)")
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(8)
            }

            Button {
                Task {
                    await appState.signUp(email: email, password: password, username: username, birthday: birthday, gender: gender)
                }
            } label: {
                Text("Create Account")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

