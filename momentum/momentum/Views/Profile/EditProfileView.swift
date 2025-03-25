//
//  EditProfileView.swift
//  Momentm
//
//  Created by matt on 9/22/24.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct EditProfileView: View {
    
    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var city: String = ""
    @State private var birthday = Date()
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var gender: String = ""
    
    //@State private var isLoading = true
    
    @State private var showingGenderPicker = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage? = nil
    
    @Environment(\.presentationMode) var presentationMode
    
    var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    var body: some View {
        NavigationView {
//            if isLoading {
//                ProgressView("Loading Profile...")
//            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Section() {
                            HStack {
                                Button(action: {
                                    showingImagePicker.toggle()
                                }) {
                                    Circle()
                                        .fill(Color(UIColor.systemGray))
                                        .frame(width: 80, height: 80)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                        .overlay(
                                            Group {
                                                if let image = selectedImage {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .clipShape(Circle())
                                                } else {
                                                    Image(systemName: "person")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 40, height: 40)
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        )
                                }
                                TextField("Name", text: $name)
                                    .padding()
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(8)
                            }
                            TextField("Bio", text: $bio)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                            TextField("City", text: $city)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                        Section(header: Text("Athlete Info")) {
                            HStack {
                                Text("Birthday")
                                DatePicker("Birthday", selection: $birthday, in: ...Date(), displayedComponents: [.date])
                                    .datePickerStyle(DefaultDatePickerStyle())
                                    .labelsHidden()
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
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
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                            }
                            HStack {
                                Text("Weight (kg)")
                                TextField("", text: $weight)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            HStack {
                                Text("Height (cm)")
                                TextField("", text: $height)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    Task {
                        await loadUserData()
                    }
                }
                .navigationTitle("Edit Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Edit Profile")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.vertical, 5) // Adjust vertical padding
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .cornerRadius(8)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            if let userId = userId {
                                Task {
                                    await saveProfile(userId: userId)
                                }
                            } else {
                                print("User is not authenticated.")
                            }
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Save")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .cornerRadius(8)
                    }
                }
                .sheet(isPresented: $showingGenderPicker) {
                    GenderPicker(gender: $gender)
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(selectedImage: $selectedImage)
                }
            //}
        }
    }
    
    func saveProfile(userId: String) async {
        do {
            try await UserManager.shared.updateUserData(
                userId: userId,  // Replace with the actual user ID
                display_name: name.isEmpty ? nil : name,
                bio: bio.isEmpty ? nil : bio,
                city: city.isEmpty ? nil : city,
                birthday: birthday,
                gender: gender.isEmpty ? nil : gender,
                weight: weight.isEmpty ? nil : weight,
                height: height.isEmpty ? nil : height
            )
        } catch {
            print("Failed to update user data: \(error.localizedDescription)")
        }
    }
    
    func loadUserData() async {
        if let userId = Auth.auth().currentUser?.uid {
            do {
                if let userData = try await UserManager.shared.fetchUserData(userId: userId) {
                    self.name = userData.display_name ?? ""
                    self.bio = userData.bio ?? ""
                    self.city = userData.city ?? ""
                    self.birthday = userData.birthday ?? Date()
                    self.gender = userData.gender ?? ""
                    self.height = userData.height ?? ""
                    self.weight = userData.weight ?? ""
                }
            } catch {
                print("Error loading user data: \(error)")
            }
            //isLoading = false
        }
    }
    
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct GenderPicker: View {
    @Binding var gender: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Picker("Gender", selection: $gender) {
                Text("").tag("")
                Text("Male").tag("Male")
                Text("Female").tag("Female")
                Text("Other").tag("Other")
            }
            .pickerStyle(WheelPickerStyle())
            .navigationTitle("Select Gender")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
