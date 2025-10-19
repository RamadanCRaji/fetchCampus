//
//  WelcomeView.swift
//  Fetch
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            Text("Welcome Screen")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    WelcomeView()
}

