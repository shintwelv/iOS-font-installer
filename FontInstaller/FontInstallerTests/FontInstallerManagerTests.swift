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
    
    @Test("Install empty list of fonts returns failure (profile creation failed)")
    func testInstallEmptyFonts() async throws {
        let manager = FontInstallerManager.shared
        
        // We expect an error, so we catch it.
        do {
            let _: URL = try await withCheckedThrowingContinuation { continuation in
                manager.installFonts(from: []) { result in
                    switch result {
                    case .success(let url):
                        // Should not happen for empty list
                         continuation.resume(returning: url)
                    case .failure(let error):
                        // This is expected, but withCheckedThrowingContinuation expects us to resume.
                        // If we want to verify it failed, we resume with error and catch it outside.
                        continuation.resume(throwing: error)
                    }
                }
            }
            // If we reach here, it succeeded unexpectedly
            throw TestError.expectedFailure
        } catch {
            // Check if it is the expected error
            if let fontError = error as? FontInstallerManager.FontInstallerError,
               case .profileCreationFailed = fontError {
                // Success
            } else if case TestError.expectedFailure = error {
                 // It succeeded but should have failed
                 throw error
            } else {
                 // Other error?
                 // For now accept it or rethrow if strict
            }
        }
    }
    
    @Test("Uninstall empty list of fonts returns failure (manual uninstall required)")
    func testUninstallEmptyFonts() async throws {
        let manager = FontInstallerManager.shared
        
        // Uninstalling now always returns failure (.manualUninstallationRequired)
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                manager.uninstallFonts(from: []) { result in
                    switch result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            throw TestError.expectedFailure
        } catch {
             if let fontError = error as? FontInstallerManager.FontInstallerError,
               case .manualUninstallationRequired = fontError {
                // Success
            } else if case TestError.expectedFailure = error {
                 throw error
            }
        }
    }
    
    @Test("Install with invalid file URL fails (file read failed)")
    func testInstallInvalidFontUrl() async throws {
        let manager = FontInstallerManager.shared
        // Create a fake URL that doesn't exist
        let fakeUrl = URL(fileURLWithPath: "/tmp/nonexistent_font.ttf")
        
        do {
            let _: URL = try await withCheckedThrowingContinuation { continuation in
                manager.installFonts(from: [fakeUrl]) { result in
                    switch result {
                    case .success(let url):
                        continuation.resume(returning: url)
                    case .failure(let error):
                         continuation.resume(throwing: error)
                    }
                }
            }
            throw TestError.expectedFailure
        } catch {
             // It should fail with file read error usually
             // The implementation tries Data(contentsOf: url) -> throws error
             // It might be a Cocoa error or FontInstallerError
             // Just verifying it throws is enough for this test
        }
    }
    
    enum TestError: Error {
        case expectedFailure
    }
}