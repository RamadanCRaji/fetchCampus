//
//  SignUpView.swift
//  Fetch
//

import SwiftUI

struct SignUpView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            Text("Sign Up Screen")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    SignUpView()
}

