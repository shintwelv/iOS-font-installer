//
//  FontInstallerManager.swift
//  FontInstaller
//
//  Created by ShinIl Heo on 1/12/26.
//

import Foundation
import CoreText
import UIKit

class FontInstallerManager {
    static let shared = FontInstallerManager()
    
    private init() {}
    
    enum FontInstallerError: Error {
        case invalidFontUrl
        case registrationFailed(Error?)
    }
    
    /// Installs fonts from the provided file URLs.
    /// - Parameters:
    ///   - urls: Array of file URLs pointing to font files (otf, ttf).
    ///   - completion: Completion handler returning success or error.
    func installFonts(from urls: [URL], completion: @escaping (Result<Void, Error>) -> Void) {
        guard !urls.isEmpty else {
            completion(.success(()))
            return
        }
        
        // Create font descriptors from URLs
        let fontDescriptors = urls.compactMap { url -> [CTFontDescriptor]? in
            // CTFontManagerCreateFontDescriptorsFromURL returns a CFArray of descriptors.
            // A font file usually contains one font, but TTC can contain multiple.
            // We'll take all descriptors found in the file.
            guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor] else {
                return nil
            }
            return descriptors
        }.flatMap { $0 }
        
        guard !fontDescriptors.isEmpty else {
            completion(.failure(FontInstallerError.invalidFontUrl))
            return
        }
        
        let descriptorsArray = fontDescriptors as CFArray
        
        // CTFontManagerScope.persistent tries to install the font for the current user,
        // making it available to other apps (on iOS 13+, this presents a system dialog).
        CTFontManagerRegisterFontDescriptors(descriptorsArray, .persistent, true) { (errors, done) -> Bool in
            if done {
                if let errors = errors as? [CFError], !errors.isEmpty {
                    // If there are errors but done is true, it might mean partial success or failure.
                    // We'll return the first error.
                    DispatchQueue.main.async {
                        completion(.failure(FontInstallerError.registrationFailed(errors.first)))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                }
            } else {
                // If not done, it might be calling this block multiple times for progress.
                // We return true to continue.
                // However, if 'errors' is populated, we might want to stop?
                // The documentation says: "The handler block returns true to continue the operation or false to terminate it."
                if let errors = errors as? [CFError], !errors.isEmpty {
                     DispatchQueue.main.async {
                        completion(.failure(FontInstallerError.registrationFailed(errors.first)))
                     }
                     return false
                }
            }
            return true
        }
    }
    
    /// Unregisters fonts.
    /// - Parameters:
    ///   - urls: Array of file URLs pointing to the font files to unregister.
    ///   - completion: Completion handler.
    func uninstallFonts(from urls: [URL], completion: @escaping (Result<Void, Error>) -> Void) {
         guard !urls.isEmpty else {
             completion(.success(()))
             return
         }
         
         let fontDescriptors = urls.compactMap { url -> [CTFontDescriptor]? in
             guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor] else {
                 return nil
             }
             return descriptors
         }.flatMap { $0 }
         
         guard !fontDescriptors.isEmpty else {
             completion(.failure(FontInstallerError.invalidFontUrl))
             return
         }
         
         let descriptorsArray = fontDescriptors as CFArray
         
         CTFontManagerUnregisterFontDescriptors(descriptorsArray, .persistent) { (errors, done) -> Bool in
             if done {
                 if let errors = errors as? [CFError], !errors.isEmpty {
                     DispatchQueue.main.async {
                         completion(.failure(FontInstallerError.registrationFailed(errors.first)))
                     }
                 } else {
                     DispatchQueue.main.async {
                         completion(.success(()))
                     }
                 }
             } else {
                 if let errors = errors as? [CFError], !errors.isEmpty {
                      DispatchQueue.main.async {
                         completion(.failure(FontInstallerError.registrationFailed(errors.first)))
                      }
                      return false
                 }
             }
             return true
         }
    }
}
