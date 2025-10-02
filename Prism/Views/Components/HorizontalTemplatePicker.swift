//
//  HorizontalTemplatePicker.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/10/02.
//

import SwiftUI

struct HorizontalTemplatePicker: View {
    @Binding var selection: ProviderTemplate?
    let templates: [ProviderTemplate]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(templates, id: \.name) { template in
                    Button(action: {
                        selection = template
                    }) {
                        HStack(spacing: 6) {
                            Image(template.icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)

                            Text(template.name)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .styledContainer(style: isSelected(template) ? .selected : .notSelected)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
        .clipped()
    }

    private func isSelected(_ template: ProviderTemplate) -> Bool {
        selection?.name == template.name
    }
}
