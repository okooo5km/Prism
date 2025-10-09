//
//  TemplatePicker.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/10/02.
//

import SwiftUI

struct TemplatePicker: View {
    @Binding var selection: ProviderTemplate?
    let templates: [ProviderTemplate]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 8) {
                ForEach(templates, id: \.name) { template in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selection = template
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(template.icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18)

                            Text(template.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            if template.name == selection?.name {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                        .styledContainer(style: isSelected(template) ? .selected : .notSelected)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
        }
        .frame(maxHeight: 320)
        .focusable(false)
    }

    private func isSelected(_ template: ProviderTemplate) -> Bool {
        selection?.name == template.name
    }
}
