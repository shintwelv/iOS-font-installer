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
                    // 1. 파일을 Data 객체로 직접 읽어옵니다. (권한이 있을 때 메모리로 복사)
                let fontData = try Data(contentsOf: url)

                    // 2. Data로부터 CGDataProvider 생성
                guard let provider = CGDataProvider(data: fontData as CFData),
                      let cgFont = CGFont(provider) else {
                    errorMessage = "Could not create Font"
                    return
                }

                    // 3. PostScript 이름 추출 (메타데이터)
                if let postScriptName = cgFont.postScriptName as String? {
                    self.fontPostScriptName = postScriptName
                    self.fontFamilyName = cgFont.fullName as String? ?? ""
                    self.fontDisplayName = url.lastPathComponent

                    // 4. 메모리에 있는 CGFont를 등록
                    var error: Unmanaged<CFError>?
                    if CTFontManagerRegisterGraphicsFont(cgFont, &error) {
                        self.previewFont = Font.custom(postScriptName, size: 24)
                    } else {
                            // 이미 등록된 경우 등을 처리
                        self.previewFont = Font.custom(postScriptName, size: 24)
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
