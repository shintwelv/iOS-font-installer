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
    @State private var showPreviewFileImporter = false
    @State private var isProcessing = false
    @State private var errorMessage: String? = nil
    @State private var generatedProfileURL: URL? = nil
    @State private var showInstallGuide = false
    @State private var previewFontUrl: URL? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "textformat.size")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.tint)
                
                Text("app_title")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("app_description")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                if isProcessing {
                    ProgressView("status_installing")
                }
                
                Button(action: {
                    errorMessage = nil
                    showFileImporter = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("button_select_files")
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
                
                Button(action: {
                    errorMessage = nil
                    showPreviewFileImporter = true
                }) {
                    HStack {
                        Image(systemName: "eye")
                        Text("button_preview_font")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.secondary.opacity(0.15))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
                .disabled(isProcessing)
                .padding(.horizontal, 40)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showInstallGuide = true
                    }) {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
            .sheet(isPresented: $showInstallGuide) {
                ProfileGuideView()
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.font],
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result)
            }
            .fileImporter(
                isPresented: $showPreviewFileImporter,
                allowedContentTypes: [.font],
                allowsMultipleSelection: false
            ) { result in
                handlePreviewFileImport(result)
            }
            .sheet(item: $previewFontUrl) { url in
                FontPreviewView(fontUrl: url)
            }
            .sheet(item: $generatedProfileURL) { url in
                ActivityViewController(activityItems: [url])
            }
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard !urls.isEmpty else {
                return
            }
            installFonts(urls)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    private func handlePreviewFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            previewFontUrl = url
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    private func installFonts(_ urls: [URL]) {
        isProcessing = true
        
        // Start accessing security scoped resources for each URL
        // We only keep the ones we successfully accessed
        let accessibleUrls = urls.filter { $0.startAccessingSecurityScopedResource() }
        
        guard !accessibleUrls.isEmpty else {
            isProcessing = false
            errorMessage = NSLocalizedString("status_access_error", comment: "Could not access the selected files.")
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
                case .success(let profileUrl):
                    errorMessage = nil
                    generatedProfileURL = profileUrl
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// Helper for UIActivityViewController
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Extension to make URL Identifiable for sheet(item:)
extension URL: Identifiable {
    public var id: String { absoluteString }
}

#Preview {
    ContentView()
}