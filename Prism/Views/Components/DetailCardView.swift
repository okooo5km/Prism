//
//  DetailCardView.swift
//  KeygenGo
//
//  Created by 十里 on 2024/7/5.
//

import SwiftUI

struct DetailTextCardView: View {
    
    let title: String
    let systemImage: String
    let value: String
    
    @State
    private var isCopied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                Text(title)
                if isCopied {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Copied")
                    }
                    .font(.system(size: 8, weight: .bold))
                    .padding(2)
                    .background(cornerRadius: 4, fill: .background)
                }
                Spacer()
            }
            .font(.subheadline)
            .foregroundStyle(.tertiary)
            
            Text(value)
                .font(.caption)
                .textSelection(.enabled)
        }
        .padding(8)
        .background(cornerRadius: 12, strokeColor: .primary.opacity(0.04), fill: .background.opacity(0.2))
        .onTapGesture(count: 2, perform: {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(value, forType: .string)
            isCopied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isCopied = false
            }
        })
    }
}

struct DetailTextCardView2: View {
    
    let title: String
    let systemImage: String
    let value: String
    
    @State
    private var isCopied = false
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                Text(title)
                if isCopied {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Copied")
                    }
                    .font(.system(size: 8, weight: .bold))
                    .padding(2)
                    .background(cornerRadius: 4, fill: .background)
                }
                Spacer()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            HStack {
                Text(value)
                    .font(.caption)
                    .fontWeight(.light)
                    .textSelection(.enabled)
                    .font(.caption)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(8)
            .background(cornerRadius: 8, strokeColor: .primary.opacity(0.03), fill: .background.opacity(0.2))
        }
        .onTapGesture(count: 2, perform: {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(value, forType: .string)
            withAnimation {
                isCopied = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    isCopied = false
                }
            }
        })
    }
}

struct DetailTextFieldCardView: View {
    
    let title: String
    let systemImage: String
    var placeholder: String = ""
    var required: Bool = false
    var isEditing: Bool = false
    var validation: (String) -> Bool = { _ in true }
    var validationMessage: String = "Invalid input"
    
    @Binding
    var value: String
    
    @State
    private var isCopied = false
    
    private var validationError: Bool {
        if value.isEmpty {
            return false
        } else {
            return !validation(value)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: systemImage)
                    Text(title)
                    if isEditing {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundStyle(.blue)
                    }
                    if isCopied {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Copied")
                        }
                        .font(.system(size: 8, weight: .bold))
                        .padding(2)
                        .background(cornerRadius: 4, fill: .background)
                    }
                    if validationError {
                        Text(validationMessage)
                            .font(.caption)
                            .fontWeight(.light)
                    }
                    if required && value.isEmpty {
                        Text("*")
                            .font(.system(size: 12, weight: .heavy, design: .monospaced))
                            .foregroundStyle(.red)
                    }
                    Spacer()
                }
            }
            .font(.subheadline)
            .foregroundStyle(.tertiary)
            
            HStack {
                TextField(placeholder, text: $value)
                    .font(.caption)
                    .textFieldStyle(.plain)
                if !(value.isEmpty) {
                    Button(action: {
                        value = ""
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    })
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(
                cornerRadius: 8,
                strokeColor: validationError ? .red : .primary.opacity(0.04),
                strokeWidth: validationError ? 2 : 1,
                fill: .background
            )
        }
        .padding(8)
        .background(cornerRadius: 12, strokeColor: .primary.opacity(0.08), fill: .background.opacity(0.6))
        .onTapGesture(count: 2, perform: {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(value, forType: .string)
            withAnimation {
                isCopied = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    isCopied = false
                }
            }
        })
    }
}

struct DetailSecureFieldCardView: View {
    
    let title: String
    let systemImage: String
    var placeholder: String = ""
    var required: Bool = false
    var isEditing: Bool = false
    
    @Binding
    var value: String
    
    @State
    private var isShowing: Bool = false
    
    @State
    private var isCopied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
                HStack(spacing: 4) {
                    Image(systemName: systemImage)
                    Text(title)
                    Spacer()
                    if required {
                        Text("*")
                            .font(.system(size: 12, weight: .heavy, design: .monospaced))
                            .foregroundStyle(.red)
                    }
                }
                
                if isEditing {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundStyle(.blue)
                }
                if isCopied {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Copied")
                    }
                    .font(.system(size: 8, weight: .bold))
                    .padding(2)
                    .background(cornerRadius: 4, fill: .background)
                }
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isShowing.toggle()
                    }
                }, label: {
                    Image(systemName: isShowing ? "eye.slash.fill" : "eye.fill")
                })
                .buttonStyle(.plain)
                .padding(.trailing, 5)
            }
            .font(.subheadline)
            .foregroundStyle(.tertiary)
            
            HStack {
                if isShowing {
                    TextField(placeholder, text: $value)
                        .font(.caption)
                        .textFieldStyle(.plain)
                } else {
                    SecureField(placeholder, text: $value)
                        .font(.caption)
                        .textFieldStyle(.plain)
                }
                    
                if !(value.isEmpty) {
                    Button(action: {
                        value = ""
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    })
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(cornerRadius: 8, strokeColor: .primary.opacity(0.04), fill: .background)
        }
        .padding(8)
        .background(cornerRadius: 12, strokeColor: .primary.opacity(0.08), fill: .background.opacity(0.6))
        .onTapGesture(count: 2, perform: {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(value, forType: .string)
            withAnimation {
                isCopied = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    isCopied = false
                }
            }
        })
    }
}

struct DetailPickerCardView<SelectionValue, Content> : View where SelectionValue : Hashable, Content : View {
    
    let title: String
    let systemImage: String
    let emptyMessage: String = "No items"
    var isEditing: Bool = false
    @Binding var isLoading: Bool
    @Binding var selection: SelectionValue
    let content: () -> Content
    
    init(_ titleKey: String,
         systemImage: String,
         isEditing: Bool = false,
         isLoading: Binding<Bool> = .constant(false),
         selection: Binding<SelectionValue>,
         @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = titleKey
        self.systemImage = systemImage
        self.isEditing = isEditing
        self._isLoading = isLoading
        self._selection = selection
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                Text(title)
                if isEditing {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundStyle(.blue)
                }
                Spacer()
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.5, anchor: .center)
                }
            }
            .font(.subheadline)
            .foregroundStyle(.tertiary)
            
            Picker("", selection: $selection) {
                content()
            }
        }
        .padding(8)
        .background(cornerRadius: 12, strokeColor: .primary.opacity(0.08), fill: .background.opacity(0.6))
    }
}

struct DetailMetadataCardView: View {
    
    let title: String
    let systemImage: String
    var value: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
                Label(title, systemImage: systemImage)
                Spacer()
            }
            .font(.subheadline)
            .foregroundStyle(.tertiary)
            
            if value.isEmpty {
                Text("No metadata")
                    .font(.caption)
            } else {
                VStack(spacing: 4) {
                    ForEach(value.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack(spacing: 4) {
                            Text(key)
                                .fontWeight(.bold)
                            Text("→")
                            Text(value)
                                .fontWeight(.light)
                            Spacer()
                        }
                        .font(.caption)
                        .textSelection(.enabled)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .padding(8)
                        .background(cornerRadius: 8, strokeColor: .primary.opacity(0.03), fill: .background.opacity(0.3))
                    }
                }
            }
        }
        .padding(8)
        .background(cornerRadius: 12, strokeColor: .primary.opacity(0.08), fill: .background.opacity(0.3))
    }
}

struct MetadataItem: Identifiable, Equatable {
    let id = UUID()
    var key: String
    var value: String
}

struct DetailMetadataEditorCardView: View {
    
    let title: String
    let systemImage: String
    var isEditing: Bool = false
    
    @Binding
    var value: [String: String?]
    
    @State
    private var metadataItems: [MetadataItem] = []
    
    @State
    private var keyDuplicationError = false
    
    @State
    private var duplicateKey: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
                Label(title, systemImage: systemImage)
                if isEditing {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundStyle(.blue)
                }
                if keyDuplicationError {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Key duplication(\(duplicateKey ?? "null"))")
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                }
                Spacer()
                Button(action: {
                    withAnimation {
                        addNewItem()
                    }
                }, label: {
                    Image(systemName: "plus")
                        .padding(4)
                        .background(cornerRadius: 4, fill: .background)
                })
                .buttonStyle(.plain)
            }
            .font(.subheadline)
            .foregroundStyle(.tertiary)
            if !(value.isEmpty) {
                VStack(spacing: 4) {
                    ForEach($metadataItems) { $item in
                        HStack(spacing: 4) {
                            TextField("Key", text: $item.key)
                                .fontWeight(.bold)
                                .padding(8)
                                .textFieldStyle(.plain)
                                .background(cornerRadius: 8, strokeColor: .primary.opacity(0.03), fill: .background
                                ).overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 2)
                                        .foregroundStyle(keyDuplicationError && duplicateKey == item.key ? Color.red : Color.clear)
                                }
                            Text("→")
                            TextField("Value", text: $item.value)
                                .fontWeight(.light)
                                .padding(8)
                                .textFieldStyle(.plain)
                                .background(cornerRadius: 8, strokeColor: .primary.opacity(0.03), fill: .background
                                )
                            Button(action: {
                                removeItem(id: item.id)
                            }, label: {
                                Image(systemName: "xmark.circle.fill")
                            })
                            .buttonStyle(.plain)
                        }
                        .font(.caption)
                        .foregroundStyle(.primary)
                    }
                }
            }
        }
        .padding(8)
        .background(cornerRadius: 12, strokeColor: .primary.opacity(0.08), fill: .background.opacity(0.6)
        ).onAppear {
            loadMetadataItems()
        }.onChange(of: metadataItems) { _, newValue in
            updateValue()
        }
    }
    
    private func loadMetadataItems() {
        metadataItems = value.map { MetadataItem(key: $0.key, value: $0.value ?? "") }
    }
    
    private func updateValue() {
        let keys = metadataItems.map({ $0.key })
        if keys.count != Set(keys).count {
            duplicateKey = keys.first(where: { key in keys.filter({ $0 == key }).count > 1 })
            withAnimation {
                keyDuplicationError = true
            }
            return
        }
        if keyDuplicationError {
            withAnimation {
                keyDuplicationError = false
                duplicateKey = nil
            }
        }
        value = Dictionary(uniqueKeysWithValues: metadataItems.map { ($0.key, $0.value) })
    }
    
    private func addNewItem() {
        metadataItems.append(MetadataItem(key: "", value: ""))
    }
    
    private func removeItem(id: UUID) {
        metadataItems.removeAll { $0.id == id }
    }
}

struct DetailSwitchCardView: View {
    
    let title: String
    let systemImage: String
    var isEditing: Bool = false
    
    @Binding
    var value: Bool
    
    var body: some View {
        HStack{
            Label(title, systemImage: systemImage)
            if isEditing {
                Image(systemName: "pencil.circle.fill")
                    .foregroundStyle(.blue)
            }
            Spacer()
            Toggle("", isOn: $value)
                .controlSize(.mini)
                .toggleStyle(.switch)
        }
        .font(.subheadline)
        .foregroundStyle(.tertiary)
        .padding(8)
        .background(cornerRadius: 12, strokeColor: .primary.opacity(0.08), fill: .background.opacity(0.6))
    }
}

struct DetailSwitchShowCardView: View {
    
    let title: String
    let systemImage: String
    var value: Bool
    
    var body: some View {
        HStack{
            Label(title, systemImage: systemImage)
            Spacer()
            Toggle("", isOn: .constant(value))
                .controlSize(.mini)
                .toggleStyle(.switch)
                .disabled(true)
        }
        .font(.subheadline)
        .foregroundStyle(.tertiary)
        .padding(8)
        .background(cornerRadius: 12, strokeColor: .primary.opacity(0.08), fill: .background.opacity(0.3))
    }
}

struct DetailIntCardView: View {
    
    let title: String
    let systemImage: String
    var value: Int?
    
    var body: some View {
        HStack{
            Label(title, systemImage: systemImage)
                .foregroundStyle(.tertiary)
                .font(.subheadline)
            Spacer()
            if let value = value {
                Text("\(value)")
            } else {
                Text("null")
            }
        }
        .font(.caption)
        .padding(8)
        .background(cornerRadius: 12, strokeColor: .primary.opacity(0.08), fill: .background.opacity(0.3))
    }
}

struct DetailIntStepperCardView: View {
    
    let title: String
    let systemImage: String
    var isEditing: Bool = false
    
    @Binding
    var value: Int?
    
    private var numberBinding: Binding<Int> {
        Binding {
            if let value = value {
                return value
            } else {
                return 0
            }
        } set: {
            if $0 == -1 {
                value = nil
            } else {
                value = $0
            }
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
            Text(title)
            if isEditing {
                Image(systemName: "pencil.circle.fill")
                    .foregroundStyle(.blue)
            }
            Spacer()
            if let value = value {
                Stepper("\(value)", value: numberBinding, in: (-1)...(Int.max-1))
                    .foregroundStyle(.primary)
            } else {
                Button(action: {
                    value = 1
                }, label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Set")
                    }
                    .foregroundStyle(.primary)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(4)
                    .background(cornerRadius: 8, fill: .background)
                })
                .buttonStyle(.plain)
            }
        }
        .font(.subheadline)
        .foregroundStyle(.tertiary)
        .padding(8)
        .background(cornerRadius: 12, strokeColor: .primary.opacity(0.08), fill: .background.opacity(0.6))
    }
}

struct DetailNilCardView: View {
    
    let title: String
    let systemImage: String
    var isEditing: Bool = false
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
            Text(title)
            if isEditing {
                Image(systemName: "pencil.circle.fill")
                    .foregroundStyle(.blue)
            }
            Spacer()
            
            Button(action: action, label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                    Text("Set")
                }
                .foregroundStyle(.primary)
                .font(.caption)
                .fontWeight(.bold)
                .padding(4)
                .background(cornerRadius: 8, fill: .background)
            })
            .buttonStyle(.plain)
        }
        .font(.subheadline)
        .foregroundStyle(.tertiary)
        .padding(8)
        .background(cornerRadius: 12, strokeColor: .primary.opacity(0.08), fill: .background.opacity(0.6))
    }
}
