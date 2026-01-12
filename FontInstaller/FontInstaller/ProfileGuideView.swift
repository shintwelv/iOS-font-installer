//
//  ProfileGuideView.swift
//  FontInstaller
//
//  Created by ShinIl Heo on 1/12/26.
//

import SwiftUI

struct ProfileGuideView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("guide_mode", selection: $selectedTab) {
                    Text("guide_mode_install").tag(0)
                    Text("guide_mode_uninstall").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(selectedTab == 0 ? "guide_install_title" : "guide_uninstall_title")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        if selectedTab == 0 {
                            InstallationGuideContent()
                        } else {
                            UninstallationGuideContent()
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("button_close")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.top, 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("guide_nav_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("button_done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InstallationGuideContent: View {
    var body: some View {
        VStack(spacing: 20) {
            StepView(
                stepNumber: 1,
                title: "guide_step1_title",
                description: "guide_step1_desc",
                iconName: "square.and.arrow.up"
            )
            
            StepView(
                stepNumber: 2,
                title: "guide_step2_title",
                description: "guide_step2_desc",
                iconName: "gear"
            )
            
            StepView(
                stepNumber: 3,
                title: "guide_step3_title",
                description: "guide_step3_desc",
                iconName: "checkmark.shield"
            )
        }
    }
}

struct UninstallationGuideContent: View {
    var body: some View {
        VStack(spacing: 20) {
            StepView(
                stepNumber: 1,
                title: "guide_uninstall_step1_title",
                description: "guide_uninstall_step1_desc",
                iconName: "gear"
            )
            
            StepView(
                stepNumber: 2,
                title: "guide_uninstall_step2_title",
                description: "guide_uninstall_step2_desc",
                iconName: "list.bullet.rectangle.portrait"
            )
            
            StepView(
                stepNumber: 3,
                title: "guide_uninstall_step3_title",
                description: "guide_uninstall_step3_desc",
                iconName: "trash"
            )
        }
    }
}

struct StepView: View {
    let stepNumber: Int
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let iconName: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                Text("\(stepNumber)")
                    .font(.headline)
                    .foregroundStyle(.blue)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Image(systemName: iconName)
                        .foregroundStyle(.secondary)
                }
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    ProfileGuideView()
}
