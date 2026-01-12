//
//  ContentView.swift
//  FontInstaller
//
//  Created by ShinIl Heo on 1/12/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var showFileImporter = false
    @State private var statusMessage: String = "Ready to install fonts"
    @State private var isProcessing = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "textformat.size")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundStyle(.tint)
            
            Text("Font Installer")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Select OTF or TTF files to install them to your system.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            if isProcessing {
                ProgressView("Installing...")
            } else {
                Text(statusMessage)
                    .font(.headline)
                    .foregroundStyle(errorMessage == nil ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Button(action: {
                errorMessage = nil
                showFileImporter = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Select Font Files")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isProcessing)
            .padding(.horizontal, 40)
        }
        .padding()
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.font],
            allowsMultipleSelection: true
        ) { result in
            handleFileImport(result)
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard !urls.isEmpty else {
                statusMessage = "No files selected."
                return
            }
            installFonts(urls)
        case .failure(let error):
            errorMessage = error.localizedDescription
            statusMessage = "Error selecting files."
        }
    }
    
    private func installFonts(_ urls: [URL]) {
        isProcessing = true
        statusMessage = "Preparing to install \(urls.count) fonts..."
        
        // Start accessing security scoped resources for each URL
        // We only keep the ones we successfully accessed
        let accessibleUrls = urls.filter { $0.startAccessingSecurityScopedResource() }
        
        guard !accessibleUrls.isEmpty else {
            isProcessing = false
            errorMessage = "Could not access the selected files."
            statusMessage = "Permission error."
            return
        }
        
        FontInstallerManager.shared.installFonts(from: accessibleUrls) { result in
            // Stop accessing security scoped resources
            // We must do this after the operation is complete
            defer {
                accessibleUrls.forEach { $0.stopAccessingSecurityScopedResource() }
            }
            
            DispatchQueue.main.async {
                isProcessing = false
                switch result {
                case .success:
                    errorMessage = nil
                    statusMessage = "Successfully installed \(accessibleUrls.count) fonts!"
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    statusMessage = "Installation failed."
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
