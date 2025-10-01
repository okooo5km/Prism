//
//  Models.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/9/30.
//

import Foundation

struct Provider: Identifiable, Codable {
    let id: UUID
    var name: String
    var envVariables: [String: String]
    var isActive: Bool
    var icon: String

    init(name: String, envVariables: [String: String], icon: String = "ClaudeLogo", isActive: Bool = false) {
        self.id = UUID()
        self.name = name
        self.envVariables = envVariables
        self.icon = icon
        self.isActive = isActive
    }

    init(id: UUID, name: String, envVariables: [String: String], icon: String, isActive: Bool) {
        self.id = id
        self.name = name
        self.envVariables = envVariables
        self.icon = icon
        self.isActive = isActive
    }

    enum CodingKeys: String, CodingKey {
        case id, name, envVariables, isActive, icon
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        envVariables = try container.decode([String: String].self, forKey: .envVariables)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? "ClaudeLogo"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(envVariables, forKey: .envVariables)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(icon, forKey: .icon)
    }
}

struct ProviderTemplate: Hashable, Equatable {
    let name: String
    let envVariables: [String: String]
    let icon: String

    static let zhipuAI = ProviderTemplate(
        name: "Zhipu AI",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://open.bigmodel.cn/api/anthropic",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.5-air",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.6",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.6"
        ],
        icon: "ZhipuLogo"
    )
    
    static let zai = ProviderTemplate(
        name: "z.ai",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.5-air",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.6",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.6"
        ],
        icon: "ZaiLogo"
    )
    
    static let moonshotAI = ProviderTemplate(
        name: "Moonshot AI",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://api.moonshot.cn/anthropic",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "kimi-k2-turbo-preview",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "kimi-k2-turbo-preview",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "kimi-k2-turbo-preview"
        ],
        icon: "MoonshotLogo"
    )
    
    static let otherAI = ProviderTemplate(
        name: "Custom AI",
        envVariables: [
            "ANTHROPIC_BASE_URL": "",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": ""
        ],
        icon: "OtherLogo"
    )

    static let allTemplates: [ProviderTemplate] = [
        zhipuAI,
        zai,
        moonshotAI,
        otherAI
    ]
}

extension Provider {
    static func fromTemplate(_ template: ProviderTemplate) -> Provider {
        return Provider(name: template.name, envVariables: template.envVariables, icon: template.icon)
    }
}

enum EnvKey: String, CaseIterable, Identifiable {
    case baseURL = "ANTHROPIC_BASE_URL"
    case authToken = "ANTHROPIC_AUTH_TOKEN"
    case haikuModel = "ANTHROPIC_DEFAULT_HAIKU_MODEL"
    case sonnetModel = "ANTHROPIC_DEFAULT_SONNET_MODEL"
    case opusModel = "ANTHROPIC_DEFAULT_OPUS_MODEL"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .baseURL:
            return "Base URL"
        case .authToken:
            return "Auth Token"
        case .haikuModel:
            return "Haiku Model"
        case .sonnetModel:
            return "Sonnet Model"
        case .opusModel:
            return "Opus Model"
        }
    }

    var systemImage: String {
        switch self {
        case .baseURL:
            return "link"
        case .authToken:
            return "key.fill"
        case .haikuModel:
            return "h.square.fill"
        case .sonnetModel:
            return "s.square.fill"
        case .opusModel:
            return "o.square.fill"
        }
    }

    var placeholder: String {
        switch self {
        case .baseURL:
            return "https://api.anthropic.com"
        case .authToken:
            return "Enter your API token"
        case .haikuModel:
            return "haiku"
        case .sonnetModel:
            return "sonnet"
        case .opusModel:
            return "opus"
        }
    }
}
