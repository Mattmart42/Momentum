//
//  File.swift
//  Momentm
//
//  Created by matt on 9/18/24.
//

import Foundation

import SwiftUI

struct BackButtonView: View {
    var body: some View {
        Button(action: {
            // Action to go back
            print("Back button tapped")
        }) {
            HStack {
                Image(systemName: "chevron.left") // Back arrow icon
                    .font(.title)
                    .foregroundColor(.white)
                Text("Back")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.blue) // Button background color
            .cornerRadius(8) // Rounded corners
            .shadow(radius: 4) // Shadow for depth
        }
        .padding() // Outer padding
    }
}
