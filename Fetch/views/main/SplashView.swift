//
//  SplashView.swift
//  Fetch
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            WelcomeView()
        } else {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // FC App Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color(hex: "007AFF"))
                            .frame(width: 120, height: 120)
                            .shadow(color: .blue.opacity(0.3), radius: 16, y: 4)
                        
                        Text("FC")
                            .font(.system(size: 48, weight: .black))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 24)
                    
                    // App Name
                    Text("Fetch Campus")
                        .font(.system(size: 32, weight: .bold))
                        .kerning(-0.5)
                        .foregroundColor(.black)
                        .padding(.bottom, 12)
                    
                    // Tagline
                    Text("Gift Points. Earn Status.")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(Color(hex: "8E8E93"))
                        .padding(.bottom, 60)
                    
                    // Loading
                    ProgressView()
                        .tint(Color(hex: "007AFF"))
                    
                    Spacer()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}