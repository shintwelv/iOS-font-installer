//
//  ProfileInstallGuideView.swift
//  FontInstaller
//
//  Created by ShinIl Heo on 1/12/26.
//

import SwiftUI

struct ProfileInstallGuideView: View {
    @Environment(\.dismiss) var dismiss
    var onContinue: (() -> Void)?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("guide_title")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    StepView(
                        stepNumber: 1,
                        title: "guide_step1_title",
                        description: "guide_step1_desc",
                        iconName: "square.and.arrow.down"
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
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                        onContinue?()
                    }) {
                        Text(onContinue != nil ? "button_continue" : "button_close")
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
    ProfileInstallGuideView()
}
