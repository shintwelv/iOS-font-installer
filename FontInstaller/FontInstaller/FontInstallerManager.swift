//
//  FontInstallerManager.swift
//  FontInstaller
//
//  Created by ShinIl Heo on 1/12/26.
//

import Foundation
import UIKit

@MainActor
class FontInstallerManager {
    static let shared = FontInstallerManager()
    
    private init() {}
    
    enum FontInstallerError: Error {
        case fileReadFailed
        case profileCreationFailed
        case manualUninstallationRequired
        case fileSaveFailed(Error)
    }
    
    /// Generates a .mobileconfig profile and saves it to a temporary file.
    /// - Parameters:
    ///   - urls: Array of file URLs pointing to font files (otf, ttf).
    ///   - completion: Completion handler returning the URL of the generated .mobileconfig file or error.
    func installFonts(from urls: [URL], completion: @escaping (Result<URL, Error>) -> Void) {
        guard !urls.isEmpty else {
            // No files, just return failure or maybe success with no URL?
            // Usually if called with empty list, nothing happens.
            // Let's return success with a dummy URL or fail.
            // Failing seems more appropriate for "nothing to install".
            completion(.failure(FontInstallerError.profileCreationFailed))
            return
        }
        
        Task {
            do {
                // 1. Generate Profile Data
                let profileData = try createMobileConfigData(from: urls)
                
                // 2. Save to Temporary Directory
                let tempDir = FileManager.default.temporaryDirectory
                let fileName = "Fonts_\(UUID().uuidString).mobileconfig"
                let fileURL = tempDir.appendingPathComponent(fileName)
                
                try profileData.write(to: fileURL)
                
                print("[FontInstallerManager] Profile saved to: \(fileURL)")
                completion(.success(fileURL))
                
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Unregisters fonts.
    /// Note: Configuration profiles installed manually cannot be removed programmatically.
    /// The user must remove them manually in Settings.
    func uninstallFonts(from urls: [URL], completion: @escaping (Result<Void, Error>) -> Void) {
        print("[FontInstallerManager] Programmatic uninstallation of configuration profiles is not supported on iOS.")
        print("[FontInstallerManager] Please instruct the user to go to Settings > General > VPN & Device Management to remove the font profile.")
        completion(.failure(FontInstallerError.manualUninstallationRequired))
    }
    
    // MARK: - Helper Methods
    
    private func createMobileConfigData(from urls: [URL]) throws -> Data {
        var payloadContent: [[String: Any]] = []
        var fontNames: [String] = []
        
        for url in urls {
            // Ensure we can access the file (for security scoped resources)
            // Note: The caller ContentView.swift handles startAccessingSecurityScopedResource
            let data = try Data(contentsOf: url)
            
            // Extract font metadata
            var fontName = url.lastPathComponent
            if let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor],
               let firstDescriptor = descriptors.first {
                let name = CTFontDescriptorCopyAttribute(firstDescriptor, kCTFontDisplayNameAttribute) as? String
                let postScriptName = CTFontDescriptorCopyAttribute(firstDescriptor, kCTFontNameAttribute) as? String
                fontName = name ?? postScriptName ?? url.lastPathComponent
            }
            
            fontNames.append(fontName)
            
            let fontPayload: [String: Any] = [
                "PayloadType": "com.apple.font",
                "PayloadVersion": 1,
                "PayloadIdentifier": "com.fontinstaller.font.\(UUID().uuidString)",
                "PayloadUUID": UUID().uuidString,
                "PayloadDisplayName": fontName,
                "Font": data // Plist serialization handles Data as Base64 <data>
            ]
            payloadContent.append(fontPayload)
        }
        
        let profile: [String: Any] = [
            "PayloadType": "Configuration",
            "PayloadVersion": 1,
            "PayloadIdentifier": "com.fontinstaller.profile.\(UUID().uuidString)",
            "PayloadUUID": UUID().uuidString,
            "PayloadDisplayName": "Install \(urls.count) \(urls.count > 1 ? "fonts" : "font")",
            "PayloadDescription": fontNames.joined(separator: "\n"),
            "PayloadOrganization": "Font Installer App",
            "PayloadContent": payloadContent
        ]
        
        return try PropertyListSerialization.data(fromPropertyList: profile, format: .xml, options: 0)
    }
}
