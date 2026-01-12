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

    private var registeredDescriptors: [CTFontDescriptor]?

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

                // 2. Create font descriptors from data
                guard let descriptors = CTFontManagerCreateFontDescriptorsFromData(fontData as CFData) as? [CTFontDescriptor],
                      let firstDescriptor = descriptors.first else {
                    errorMessage = "Could not create Font Descriptors from data."
                    return
                }

                // 3. Extract metadata from descriptor
                let postScriptName = CTFontDescriptorCopyAttribute(firstDescriptor, kCTFontNameAttribute) as? String ?? ""
                self.fontPostScriptName = postScriptName
                self.fontFamilyName = CTFontDescriptorCopyAttribute(firstDescriptor, kCTFontFamilyNameAttribute) as? String ?? ""
                self.fontDisplayName = CTFontDescriptorCopyAttribute(firstDescriptor, kCTFontDisplayNameAttribute) as? String ?? url.lastPathComponent

                // 4. Register descriptors for preview (Process-scope)
                CTFontManagerRegisterFontDescriptors(descriptors as CFArray, .process, true) { [weak self] (errors, done) -> Bool in
                    if done {
                        DispatchQueue.main.async {
                            guard let self = self else { return }
                            self.registeredDescriptors = descriptors
                            if !postScriptName.isEmpty {
                                self.previewFont = Font.custom(postScriptName, size: 24)
                            }
                        }
                    }
                    return true
                }
            } catch {
                self.errorMessage = "Could not read Font file: \(error.localizedDescription)"
            }
        }
    }

    deinit {
        // Unregister descriptors on deinit
        if let descriptors = registeredDescriptors {
            CTFontManagerUnregisterFontDescriptors(descriptors as CFArray, .process) { _, _ in true }
        }
    }
}