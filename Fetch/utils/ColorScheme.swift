//
//  ColorScheme.swift
//  Fetch
//
//  Adaptive color scheme for light/dark mode support
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors
    
    static let fetchBlue = Color("FetchBlue", bundle: nil, default: Color(hex: "007AFF"))
    static let fetchPurple = Color("FetchPurple", bundle: nil, default: Color(hex: "5856D6"))
    
    // MARK: - Background Colors
    
    static let fetchBackground = Color("Background", bundle: nil, default: Color(hex: "F2F2F7"))
    static let fetchCardBackground = Color("CardBackground", bundle: nil, default: .white)
    static let fetchSecondaryBackground = Color("SecondaryBackground", bundle: nil, default: Color(hex: "E5E5EA"))
    
    // MARK: - Text Colors
    
    static let fetchPrimaryText = Color("PrimaryText", bundle: nil, default: .black)
    static let fetchSecondaryText = Color("SecondaryText", bundle: nil, default: Color(hex: "8E8E93"))
    static let fetchTertiaryText = Color("TertiaryText", bundle: nil, default: Color(hex: "C7C7CC"))
    
    // MARK: - Semantic Colors
    
    static let fetchSuccess = Color("Success", bundle: nil, default: Color(hex: "34C759"))
    static let fetchError = Color("Error", bundle: nil, default: Color(hex: "FF3B30"))
    static let fetchWarning = Color("Warning", bundle: nil, default: Color(hex: "FF9500"))
    
    // MARK: - Helper initializer
    
    init(_ name: String, bundle: Bundle?, default defaultColor: Color) {
        if let color = UIColor(named: name, in: bundle, compatibleWith: nil) {
            self.init(uiColor: color)
        } else {
            self = defaultColor
        }
    }
}

// MARK: - Dark Mode Preview Helper

extension View {
    func previewInDarkMode() -> some View {
        self.preferredColorScheme(.dark)
    }
    
    func previewInAllColorSchemes() -> some View {
        Group {
            self.preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            self.preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}

