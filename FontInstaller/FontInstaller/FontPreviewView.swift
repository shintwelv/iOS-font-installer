//
//  FontPreviewView.swift
//  FontInstaller
//
//  Created by ShinIl Heo on 1/12/26.
//

import SwiftUI

struct FontPreviewView: View {
    let fontUrl: URL
    @StateObject private var viewModel = FontPreviewViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Metadata Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Font Details")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                DetailRow(label: "Name", value: viewModel.fontDisplayName)
                                DetailRow(label: "Family", value: viewModel.fontFamilyName)
                                DetailRow(label: "PostScript", value: viewModel.fontPostScriptName)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            
                            Divider()
                            
                            // Preview Section
                            Text("Preview")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            if let previewFont = viewModel.previewFont {
                                VStack(spacing: 20) {
                                    Text("ABCDEFGHIJKLM\nNOPQRSTUVWXYZ")
                                        .font(previewFont)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                    
                                    Text("abcdefghijklm\nnopqrstuvwxyz")
                                        .font(previewFont)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                    
                                    Text("1234567890\n!@#$%^&*()_+")
                                        .font(previewFont)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                    
                                    Text("The quick brown fox jumps over the lazy dog.")
                                        .font(previewFont)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 2)
                            } else {
                                Text("Generating preview...")
                                    .italic()
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Font Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadFont(from: fontUrl)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.subheadline)
                .bold()
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.subheadline)
        }
    }
}

#Preview {
    // Note: This preview might fail if no valid font URL is provided.
    // In a real app run, it works with the file importer.
    Text("Font Preview Placeholder")
}
