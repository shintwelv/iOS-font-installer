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
            let accessing = url.startAccessingSecurityScopedResource()
            defer {
                if accessing { url.stopAccessingSecurityScopedResource() }
                isLoading = false
            }

            do {
                // 1. Read font data from URL
                let fontData = try Data(contentsOf: url)
                
                // 2. Create font descriptors from data as requested
                guard let descriptors = CTFontManagerCreateFontDescriptorsFromData(fontData as CFData) as? [CTFontDescriptor],
                      let firstDescriptor = descriptors.first else {
                    errorMessage = "Could not read font data."
                    return
                }

                // 3. Extract metadata
                self.fontDisplayName = CTFontDescriptorCopyAttribute(firstDescriptor, kCTFontDisplayNameAttribute) as? String ?? url.lastPathComponent
                self.fontFamilyName = CTFontDescriptorCopyAttribute(firstDescriptor, kCTFontFamilyNameAttribute) as? String ?? ""
                self.fontPostScriptName = CTFontDescriptorCopyAttribute(firstDescriptor, kCTFontNameAttribute) as? String ?? ""

                // 4. Register font for preview (Process-scope) using the URL
                var error: Unmanaged<CFError>?
                if CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                    self.registeredFontUrl = url
                    if !fontPostScriptName.isEmpty {
                        self.previewFont = Font.custom(fontPostScriptName, size: 24)
                    }
                } else {
                    // If registration failed (e.g. already registered), try to use the font anyway
                    if !fontPostScriptName.isEmpty {
                        self.previewFont = Font.custom(fontPostScriptName, size: 24)
                    } else {
                        let errorDesc = error?.takeRetainedValue().localizedDescription ?? "Unknown error"
                        errorMessage = "Failed to register font: \(errorDesc)"
                    }
                }
            } catch {
                self.errorMessage = "Could not read Font file: \(error.localizedDescription)"
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
