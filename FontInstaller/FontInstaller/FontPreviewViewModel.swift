//
//  FontPreviewViewModel.swift
//  FontInstaller
//
//  Created by ShinIl Heo on 1/12/26.
//

import Foundation
import SwiftUI
import CoreText
import Combine

@MainActor
class FontPreviewViewModel: ObservableObject {
    @Published var fontDisplayName: String = ""
    @Published var fontFamilyName: String = ""
    @Published var fontPostScriptName: String = ""
    @Published var previewFont: Font?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private var registeredFontUrl: URL?
    
    func loadFont(from url: URL) {
        isLoading = true
        errorMessage = nil
        
        Task {
            // Access security scoped resource if needed
            let accessing = url.startAccessingSecurityScopedResource()
            defer {
                if accessing {
                    url.stopAccessingSecurityScopedResource()
                }
                isLoading = false
            }
            
            // 1. Create Font Descriptor to extract metadata
            guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor],
                  let firstDescriptor = descriptors.first else {
                errorMessage = "Could not read font file."
                return
            }
            
            self.fontDisplayName = CTFontDescriptorCopyAttribute(firstDescriptor, kCTFontDisplayNameAttribute) as? String ?? url.lastPathComponent
            self.fontFamilyName = CTFontDescriptorCopyAttribute(firstDescriptor, kCTFontFamilyNameAttribute) as? String ?? "Unknown Family"
            self.fontPostScriptName = CTFontDescriptorCopyAttribute(firstDescriptor, kCTFontNameAttribute) as? String ?? ""
            
            // 2. Register font for preview (Process-scope)
            // We use CTFontManagerRegisterFontsForURL with .process scope so it's available to this app immediately for rendering.
            var error: Unmanaged<CFError>?
            if CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                registeredFontUrl = url
                
                // 3. Create SwiftUI Font
                // We use the PostScript name (or unique name) to initialize the font
                if let postScriptName = self.fontPostScriptName as String?, !postScriptName.isEmpty {
                    self.previewFont = Font.custom(postScriptName, size: 24)
                } else {
                    // Fallback if we can't get the name, though registration success usually implies we can.
                    errorMessage = "Font loaded but name not found."
                }
            } else {
                // If it failed, maybe it's already registered?
                // CTFontManagerRegisterFontsForURL returns false if already registered.
                // We can try to just use it.
                if let postScriptName = self.fontPostScriptName as String?, !postScriptName.isEmpty {
                     self.previewFont = Font.custom(postScriptName, size: 24)
                } else {
                     let errorDesc = error?.takeRetainedValue().localizedDescription ?? "Unknown error"
                     errorMessage = "Failed to register font for preview: \(errorDesc)"
                }
            }
        }
    }
    
    deinit {
        // Unregister the font when the view model is deallocated to clean up
        // Note: This deinit might run on any thread, but unregistration should be safe or we should dispatch main.
        // However, making deinit async/main actor is tricky.
        // Process scope fonts stick around until the app terminates usually, so explicit unregistration isn't strictly fatal if missed,
        // but good practice.
        if let url = registeredFontUrl {
             var error: Unmanaged<CFError>?
             CTFontManagerUnregisterFontsForURL(url as CFURL, .process, &error)
        }
    }
}
