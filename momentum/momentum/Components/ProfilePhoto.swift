//
//  ProfilePhoto.swift
//  Momentm
//
//  Created by matt on 9/22/24.
//

import SwiftUI


struct ProfilePhoto: View {
    var body: some View {
        Image("profile-pic")
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.white, lineWidth: 4)
            }
    }
}

struct ProfilePhoto_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePhoto()
    }
}
