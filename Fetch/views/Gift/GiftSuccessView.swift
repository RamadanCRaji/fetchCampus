//
//  GiftSuccessView.swift
//  Fetch
//

import SwiftUI

struct GiftSuccessView: View {
    let recipientName: String
    let amount: Int
    let onDismiss: () -> Void
    
    @State private var showCheckmark = false
    @State private var showDetails = false
    @State private var confettiOpacity = 0.0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "007AFF"), Color(hex: "5856D6")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Confetti effect
            ZStack {
                ForEach(0..<20, id: \.self) { index in
                    ConfettiPiece(index: index)
                        .opacity(confettiOpacity)
                }
            }
            
            VStack(spacing: 32) {
                Spacer()
                
                // Success checkmark
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(showCheckmark ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: showCheckmark)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(showCheckmark ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.3), value: showCheckmark)
                }
                
                // Success message
                VStack(spacing: 16) {
                    Text("Gift Sent!")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(showDetails ? 1 : 0)
                        .offset(y: showDetails ? 0 : 20)
                    
                    Text("You sent \(amount) points to")
                        .font(.system(size: 17))
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(showDetails ? 1 : 0)
                        .offset(y: showDetails ? 0 : 20)
                    
                    Text(recipientName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .opacity(showDetails ? 1 : 0)
                        .offset(y: showDetails ? 0 : 20)
                }
                .animation(.easeOut(duration: 0.5).delay(0.5), value: showDetails)
                
                // Gift icon
                Text("🎁")
                    .font(.system(size: 80))
                    .opacity(showDetails ? 1 : 0)
                    .scaleEffect(showDetails ? 1 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.7), value: showDetails)
                
                Spacer()
                
                // Done button
                Button(action: onDismiss) {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "007AFF"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .opacity(showDetails ? 1 : 0)
                .offset(y: showDetails ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.9), value: showDetails)
            }
        }
        .onAppear {
            showCheckmark = true
            showDetails = true
            
            // Trigger confetti
            withAnimation(.easeOut(duration: 1.0).delay(0.4)) {
                confettiOpacity = 1.0
            }
            
            // Fade out confetti
            withAnimation(.easeOut(duration: 0.5).delay(2.0)) {
                confettiOpacity = 0.0
            }
        }
    }
}

// MARK: - Confetti Piece

struct ConfettiPiece: View {
    let index: Int
    @State private var yOffset: CGFloat = -100
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    
    let colors: [Color] = [
        Color(hex: "FF6B6B"),
        Color(hex: "4ECDC4"),
        Color(hex: "FFE66D"),
        Color(hex: "95E1D3"),
        Color(hex: "F38181"),
        .white
    ]
    
    var body: some View {
        Rectangle()
            .fill(colors[index % colors.count])
            .frame(width: 8, height: 16)
            .cornerRadius(2)
            .rotationEffect(.degrees(rotation))
            .offset(x: xOffset, y: yOffset)
            .onAppear {
                let randomX = CGFloat.random(in: -150...150)
                let randomDelay = Double.random(in: 0...0.5)
                let randomRotation = Double.random(in: 0...720)
                
                withAnimation(.easeIn(duration: 2.0).delay(randomDelay)) {
                    yOffset = 1000
                    xOffset = randomX
                    rotation = randomRotation
                }
            }
    }
}

#Preview {
    GiftSuccessView(recipientName: "Jake", amount: 200, onDismiss: {})
}

