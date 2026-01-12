//
//  FontInstallerManagerTests.swift
//  FontInstallerTests
//
//  Created by ShinIl Heo on 1/12/26.
//

import Testing
import Foundation
@testable import FontInstaller

@MainActor
struct FontInstallerManagerTests {
    
    @Test("Install empty list of fonts returns success immediately")
    func testInstallEmptyFonts() async throws {
        let manager = FontInstallerManager.shared
        
        try await withCheckedThrowingContinuation { continuation in
            manager.installFonts(from: []) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    // In Swift Testing, we can fail directly or throw.
                    // For async continuation, we just resume with error or success.
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    @Test("Uninstall empty list of fonts returns success immediately")
    func testUninstallEmptyFonts() async throws {
        let manager = FontInstallerManager.shared
        
        try await withCheckedThrowingContinuation { continuation in
            manager.uninstallFonts(from: []) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    @Test("Install with invalid file URL fails")
    func testInstallInvalidFontUrl() async throws {
        let manager = FontInstallerManager.shared
        // Create a fake URL that doesn't exist
        let fakeUrl = URL(fileURLWithPath: "/tmp/nonexistent_font.ttf")
        
        try await withCheckedThrowingContinuation { continuation in
            manager.installFonts(from: [fakeUrl]) { result in
                switch result {
                case .success:
                    // This should fail because the file doesn't exist/invalid font
                    continuation.resume(throwing: TestError.expectedFailure)
                case .failure(let error):
                    // Verify it's the expected error type if possible,
                    // but for now, just verifying it failed is enough.
                    if let fontError = error as? FontInstallerManager.FontInstallerError,
                       case .invalidFontUrl = fontError {
                        continuation.resume()
                    } else {
                        // Failed with unexpected error
                         continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    enum TestError: Error {
        case expectedFailure
    }
}
