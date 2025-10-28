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

    var displayName: String {
        switch self {
        case .string:
            return "String"
        case .integer:
            return "Integer"
        case .boolean:
            return "Boolean"
        }
    }
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
    let docLink: String?

    static let zhipuAI = ProviderTemplate(
        name: String(localized: "Zhipu AI"),
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "https://open.bigmodel.cn/api/anthropic", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": EnvValue(value: "glm-4.5-air", type: .string),
            "ANTHROPIC_DEFAULT_SONNET_MODEL": EnvValue(value: "glm-4.6", type: .string),
            "ANTHROPIC_DEFAULT_OPUS_MODEL": EnvValue(value: "glm-4.6", type: .string)
        ],
        icon: "ZhipuLogo",
        docLink: String(localized: "Zhipu AI Doc Link", defaultValue: "https://docs.bigmodel.cn/cn/coding-plan/tool/claude")
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
        icon: "ZaiLogo",
        docLink: String(localized: "Z AI Doc Link", defaultValue: "https://docs.z.ai/devpack/tool/claude")
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
        icon: "MoonshotLogo",
        docLink: String(localized: "Moonshot AI Doc Link", defaultValue: "https://platform.moonshot.cn/docs/guide/agent-support")
    )

    static let VanchinAI = ProviderTemplate(
        name: String(localized: "Vanchin"),
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "https://wanqing.streamlakeapi.com/api/gateway/v1/endpoints/xxx/claude-code-proxy", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": EnvValue(value: "KAT-Coder", type: .string),
            "ANTHROPIC_DEFAULT_SONNET_MODEL": EnvValue(value: "KAT-Coder", type: .string),
            "ANTHROPIC_DEFAULT_OPUS_MODEL": EnvValue(value: "KAT-Coder", type: .string)
        ],
        icon: "StreamLakeLogo",
        docLink: String(localized: "VanChin AI Doc Link", defaultValue: "https://www.streamlake.com/document/WANQING/me6ymdjrqv8lp4iq0o9")
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
        icon: "DeepSeekLogo",
        docLink: String(localized: "DeepSeek Doc Link", defaultValue: "https://api-docs.deepseek.com/")
    )

    static let packyCodeAI = ProviderTemplate(
        name: String(localized: "PackyCode"),
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "https://api.packycode.com", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": EnvValue(value: "1", type: .boolean)
        ],
        icon: "PackyCodeLogo",
        docLink: String(localized: "PackyCode Doc Link", defaultValue: "https://www.packycode.com/docs")
    )

    static let aliyuncsAI = ProviderTemplate(
        name: String(localized: "Aliyuncs"),
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "https://dashscope.aliyuncs.com/apps/anthropic", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": EnvValue(value: "qwen-flash", type: .string),
            "ANTHROPIC_DEFAULT_SONNET_MODEL": EnvValue(value: "qwen-max", type: .string),
            "ANTHROPIC_DEFAULT_OPUS_MODEL": EnvValue(value: "qwen-max", type: .string)
        ],
        icon: "AliyuncsLogo",
        docLink: String(localized: "Aliyuncs Doc Link", defaultValue: "https://help.aliyun.com/zh/model-studio/developer-reference/use-qwen-by-calling-api")
    )

    static let modelScopeAI = ProviderTemplate(
        name: String(localized: "ModelScope"),
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "https://api-inference.modelscope.cn", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": EnvValue(value: "Qwen/Qwen3-Coder-480B-A35B-Instruct", type: .string),
            "ANTHROPIC_DEFAULT_SONNET_MODEL": EnvValue(value: "Qwen/Qwen3-Coder-480B-A35B-Instruct", type: .string),
            "ANTHROPIC_DEFAULT_OPUS_MODEL": EnvValue(value: "deepseek-ai/DeepSeek-R1-0528", type: .string)
        ],
        icon: "ModelScopeLogo",
        docLink: String(localized: "ModelScope Doc Link", defaultValue: "https://modelscope.cn/docs/models/inference")
    )
    
    static let longCatAI = ProviderTemplate(
        name: String(localized: "LongCat"),
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "https://api.longcat.chat/anthropic", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": EnvValue(value: "LongCat-Flash-Chat", type: .string),
            "ANTHROPIC_DEFAULT_SONNET_MODEL": EnvValue(value: "LongCat-Flash-Chat", type: .string),
            "ANTHROPIC_DEFAULT_OPUS_MODEL": EnvValue(value: "LongCat-Flash-Thinking", type: .string),
            "CLAUDE_CODE_MAX_OUTPUT_TOKENS": EnvValue(value: "6000", type: .integer),
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": EnvValue(value: "1", type: .boolean)
        ],
        icon: "LongCatLogo",
        docLink: String(localized: "LongCat Doc Link", defaultValue: "https://longcat.chat/platform/docs/ClaudeCode.html")
    )
    
    static let anyRouterAI = ProviderTemplate(
        name: String(localized: "AnyRouter"),
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "https://anyrouter.top", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
        ],
        icon: "AnyRouterLogo",
        docLink: String(localized: "AnyRouter Link", defaultValue: "https://docs.anyrouter.top/")
    )
    
    static let miniMaxAI = ProviderTemplate(
        name: String(localized: "MiniMax.com"),
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "https://api.minimaxi.com/anthropic", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": EnvValue(value: "MiniMax-M2", type: .string),
            "ANTHROPIC_DEFAULT_SONNET_MODEL": EnvValue(value: "MiniMax-M2", type: .string),
            "ANTHROPIC_DEFAULT_OPUS_MODEL": EnvValue(value: "MiniMax-M2", type: .string),
            "API_TIMEOUT_MS": EnvValue(value: "3000000", type: .integer),
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": EnvValue(value: "1", type: .boolean),
        ],
        icon: "MiniMaxLogo",
        docLink: String(localized: "MiniMax Link", defaultValue: "https://platform.minimaxi.com/docs/guides/text-ai-coding-tools#%E5%9C%A8-claude-code-%E4%B8%AD%E4%BD%BF%E7%94%A8-minimax-m2%EF%BC%88%E6%8E%A8%E8%8D%90%EF%BC%89")
    )
    
    static let miniMaxIoAI = ProviderTemplate(
        name: String(localized: "MiniMax.io"),
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "https://api.minimax.io/anthropic", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": EnvValue(value: "MiniMax-M2", type: .string),
            "ANTHROPIC_DEFAULT_SONNET_MODEL": EnvValue(value: "MiniMax-M2", type: .string),
            "ANTHROPIC_DEFAULT_OPUS_MODEL": EnvValue(value: "MiniMax-M2", type: .string),
            "API_TIMEOUT_MS": EnvValue(value: "3000000", type: .integer),
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": EnvValue(value: "1", type: .boolean),
        ],
        icon: "MiniMaxLogo",
        docLink: String(localized: "MiniMax IO Link", defaultValue: "https://platform.minimax.io/docs/guides/text-ai-coding-tools#use-minimax-m2-in-claude-code-recommended")
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
        icon: "OtherLogo",
        docLink: nil
    )

    static let allTemplates: [ProviderTemplate] = [
        zhipuAI,
        zai,
        miniMaxAI,
        miniMaxIoAI,
        moonshotAI,
        VanchinAI,
        deepSeekAI,
        aliyuncsAI,
        modelScopeAI,
        packyCodeAI,
        anyRouterAI,
        longCatAI,
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
    case maxOutputTokens = "CLAUDE_CODE_MAX_OUTPUT_TOKENS"
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
        case .maxOutputTokens:
            return "Max output tokens"
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
        case .maxOutputTokens:
            return "character.textbox"
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
        case .maxOutputTokens:
            return "6000"
        case .disableTraffic:
            return "Enabled"
        }
    }

    var valueType: EnvValueType {
        switch self {
        case .baseURL, .authToken, .haikuModel, .sonnetModel, .opusModel:
            return .string
        case .apiTimeout, .maxOutputTokens:
            return .integer
        case .disableTraffic:
            return .boolean
        }
    }
}
