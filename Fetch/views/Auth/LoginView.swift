//
//  LoginView.swift
//  Fetch
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            Text("Login Screen")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    LoginView()
}

