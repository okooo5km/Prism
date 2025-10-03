//
//  Models.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/9/30.
//

import Foundation

enum EnvValueType: String, Codable {
    case string
    case integer
    case boolean
}

struct EnvValue: Codable, Equatable, Hashable {
    var value: String
    var type: EnvValueType

    init(value: String, type: EnvValueType) {
        self.value = value
        self.type = type
    }
}

struct Provider: Identifiable, Codable {
    let id: UUID
    var name: String
    var envVariables: [String: EnvValue]
    var isActive: Bool
    var icon: String

    init(name: String, envVariables: [String: EnvValue], icon: String = "ClaudeLogo", isActive: Bool = false) {
        self.id = UUID()
        self.name = name
        self.envVariables = envVariables
        self.icon = icon
        self.isActive = isActive
    }

    init(id: UUID, name: String, envVariables: [String: EnvValue], icon: String, isActive: Bool) {
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

        // Try to decode as new format first, fallback to old format for compatibility
        if let newFormat = try? container.decode([String: EnvValue].self, forKey: .envVariables) {
            envVariables = newFormat
        } else if let oldFormat = try? container.decode([String: String].self, forKey: .envVariables) {
            // Migrate old data: convert [String: String] to [String: EnvValue]
            envVariables = oldFormat.mapValues { EnvValue(value: $0, type: .string) }
        } else {
            envVariables = [:]
        }

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
    let envVariables: [String: EnvValue]
    let icon: String

    static let zhipuAI = ProviderTemplate(
        name: String(localized: "Zhipu AI"),
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "https://open.bigmodel.cn/api/anthropic", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": EnvValue(value: "glm-4.5-air", type: .string),
            "ANTHROPIC_DEFAULT_SONNET_MODEL": EnvValue(value: "glm-4.6", type: .string),
            "ANTHROPIC_DEFAULT_OPUS_MODEL": EnvValue(value: "glm-4.6", type: .string)
        ],
        icon: "ZhipuLogo"
    )
    
    static let zai = ProviderTemplate(
        name: "z.ai",
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "https://api.z.ai/api/anthropic", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": EnvValue(value: "glm-4.5-air", type: .string),
            "ANTHROPIC_DEFAULT_SONNET_MODEL": EnvValue(value: "glm-4.6", type: .string),
            "ANTHROPIC_DEFAULT_OPUS_MODEL": EnvValue(value: "glm-4.6", type: .string)
        ],
        icon: "ZaiLogo"
    )
    
    static let moonshotAI = ProviderTemplate(
        name: String(localized: "Moonshot AI"),
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "https://api.moonshot.cn/anthropic", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": EnvValue(value: "kimi-k2-turbo-preview", type: .string),
            "ANTHROPIC_DEFAULT_SONNET_MODEL": EnvValue(value: "kimi-k2-turbo-preview", type: .string),
            "ANTHROPIC_DEFAULT_OPUS_MODEL": EnvValue(value: "kimi-k2-turbo-preview", type: .string)
        ],
        icon: "MoonshotLogo"
    )
    
    static let streamLakeAI = ProviderTemplate(
        name: String(localized: "StreamLake"),
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": EnvValue(value: "KAT-Coder", type: .string),
            "ANTHROPIC_DEFAULT_SONNET_MODEL": EnvValue(value: "KAT-Coder", type: .string),
            "ANTHROPIC_DEFAULT_OPUS_MODEL": EnvValue(value: "KAT-Coder", type: .string)
        ],
        icon: "StreamLakeLogo"
    )
    
    static let deepSeekAI = ProviderTemplate(
        name: String(localized: "DeepSeek"),
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "https://api.deepseek.com/anthropic", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": EnvValue(value: "deepseek-chat", type: .string),
            "ANTHROPIC_DEFAULT_SONNET_MODEL": EnvValue(value: "deepseek-chat", type: .string),
            "ANTHROPIC_DEFAULT_OPUS_MODEL": EnvValue(value: "deepseek-chat", type: .string),
            "API_TIMEOUT_MS": EnvValue(value: "600000", type: .integer),
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": EnvValue(value: "1", type: .boolean)
        ],
        icon: "DeepSeekLogo"
    )
    
    static let otherAI = ProviderTemplate(
        name: String(localized: "Custom AI"),
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_SONNET_MODEL": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_OPUS_MODEL": EnvValue(value: "", type: .string)
        ],
        icon: "OtherLogo"
    )

    static let allTemplates: [ProviderTemplate] = [
        zhipuAI,
        zai,
        moonshotAI,
        streamLakeAI,
        deepSeekAI,
        otherAI
    ]
}

extension Provider {
    static func fromTemplate(_ template: ProviderTemplate) -> Provider {
        return Provider(name: template.name, envVariables: template.envVariables, icon: template.icon)
    }
}

enum TokenCheckResult {
    case unique
    case duplicateWithDifferentURL(Provider)
    case duplicateWithSameURL(Provider)
}

enum EnvKey: String, CaseIterable, Identifiable {
    case baseURL = "ANTHROPIC_BASE_URL"
    case authToken = "ANTHROPIC_AUTH_TOKEN"
    case haikuModel = "ANTHROPIC_DEFAULT_HAIKU_MODEL"
    case sonnetModel = "ANTHROPIC_DEFAULT_SONNET_MODEL"
    case opusModel = "ANTHROPIC_DEFAULT_OPUS_MODEL"
    case apiTimeout = "API_TIMEOUT_MS"
    case disableTraffic = "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC"

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
        case .apiTimeout:
            return "API Timeout (ms)"
        case .disableTraffic:
            return "Disable Non-essential Traffic"
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
        case .apiTimeout:
            return "clock.fill"
        case .disableTraffic:
            return "network.slash"
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
        case .apiTimeout:
            return "600000"
        case .disableTraffic:
            return "Enabled"
        }
    }

    var valueType: EnvValueType {
        switch self {
        case .baseURL, .authToken, .haikuModel, .sonnetModel, .opusModel:
            return .string
        case .apiTimeout:
            return .integer
        case .disableTraffic:
            return .boolean
        }
    }
}
