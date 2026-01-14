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
    
    static let ZenMuxAI = ProviderTemplate(
        name: String(localized: "ZenMux"),
        envVariables: [
            "ANTHROPIC_BASE_URL": EnvValue(value: "https://zenmux.ai/api/anthropic", type: .string),
            "ANTHROPIC_AUTH_TOKEN": EnvValue(value: "", type: .string),
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": EnvValue(value: "google/gemini-3-pro-preview-free", type: .string),
            "ANTHROPIC_DEFAULT_SONNET_MODEL": EnvValue(value: "google/gemini-3-pro-preview-free", type: .string),
            "ANTHROPIC_DEFAULT_OPUS_MODEL": EnvValue(value: "google/gemini-3-pro-preview-free", type: .string),
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": EnvValue(value: "1", type: .boolean),
        ],
        icon: "ZenMuxLogo",
        docLink: String(localized: "ZenMux Link", defaultValue: "https://docs.zenmux.ai/best-practices/claude-code.html")
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
        ZenMuxAI,
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

// MARK: - Claude Environment Variable Definitions

/// Represents a Claude Code environment variable with its metadata
struct ClaudeEnvVariable: Identifiable, Hashable {
    let name: String
    let shortNameKey: String
    let shortNameDefault: String
    let descriptionKey: String
    let descriptionDefault: String
    let type: EnvValueType
    let defaultValue: String?

    var id: String { name }
    
    /// Localized short name for display
    var shortName: String {
        let localized = NSLocalizedString(shortNameKey, value: shortNameDefault, comment: "")
        return localized == shortNameKey ? shortNameDefault : localized
    }
    
    /// Localized description for display
    var description: String {
        let localized = NSLocalizedString(descriptionKey, value: descriptionDefault, comment: "")
        return localized == descriptionKey ? descriptionDefault : localized
    }
    
    /// Convenience initializer using environment variable name as key base
    init(name: String, shortName: String, description: String, type: EnvValueType, defaultValue: String?) {
        self.name = name
        self.shortNameKey = "EnvVar.Short.\(name)"
        self.shortNameDefault = shortName
        self.descriptionKey = "EnvVar.Desc.\(name)"
        self.descriptionDefault = description
        self.type = type
        self.defaultValue = defaultValue
    }

    /// All available Claude Code environment variables
    static let allVariables: [ClaudeEnvVariable] = [
        // API Authentication
        ClaudeEnvVariable(name: "ANTHROPIC_API_KEY", shortName: "API Key", description: "API key sent as X-Api-Key header", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "ANTHROPIC_AUTH_TOKEN", shortName: "Auth Token", description: "Custom value for Authorization header (prefixed with Bearer)", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "ANTHROPIC_BASE_URL", shortName: "Base URL", description: "Base URL for API requests", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "ANTHROPIC_CUSTOM_HEADERS", shortName: "Custom Headers", description: "Custom headers to add to requests (Name: Value format)", type: .string, defaultValue: nil),

        // Model Configuration
        ClaudeEnvVariable(name: "ANTHROPIC_DEFAULT_HAIKU_MODEL", shortName: "Haiku Model", description: "Default model name for Haiku", type: .string, defaultValue: "claude-haiku-4-5@20251001"),
        ClaudeEnvVariable(name: "ANTHROPIC_DEFAULT_OPUS_MODEL", shortName: "Opus Model", description: "Default model name for Opus", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "ANTHROPIC_DEFAULT_SONNET_MODEL", shortName: "Sonnet Model", description: "Default model name for Sonnet", type: .string, defaultValue: "claude-sonnet-4-5@20250929"),
        ClaudeEnvVariable(name: "ANTHROPIC_MODEL", shortName: "Model Setting", description: "Model setting name to use", type: .string, defaultValue: "default"),
        ClaudeEnvVariable(name: "ANTHROPIC_SMALL_FAST_MODEL", shortName: "Small Fast Model", description: "[DEPRECATED] Haiku-class model name for background tasks", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION", shortName: "Small Model Region", description: "Override AWS region for Haiku model when using Bedrock", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "CLAUDE_CODE_SUBAGENT_MODEL", shortName: "Subagent Model", description: "Model to use for subagents", type: .string, defaultValue: nil),

        // Microsoft Foundry
        ClaudeEnvVariable(name: "ANTHROPIC_FOUNDRY_API_KEY", shortName: "Foundry API Key", description: "API key for Microsoft Foundry authentication", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "ANTHROPIC_FOUNDRY_BASE_URL", shortName: "Foundry Base URL", description: "Full base URL for Microsoft Foundry", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "ANTHROPIC_FOUNDRY_RESOURCE", shortName: "Foundry Resource", description: "Azure resource name", type: .string, defaultValue: nil),

        // Vertex AI
        ClaudeEnvVariable(name: "ANTHROPIC_VERTEX_PROJECT_ID", shortName: "Vertex Project ID", description: "GCP project ID for Vertex AI", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "CLOUD_ML_REGION", shortName: "Vertex Region", description: "Vertex AI region", type: .string, defaultValue: "global"),
        ClaudeEnvVariable(name: "VERTEX_REGION_CLAUDE_3_5_HAIKU", shortName: "Haiku 3.5 Region", description: "Region override for Claude 3.5 Haiku in Vertex AI", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "VERTEX_REGION_CLAUDE_3_7_SONNET", shortName: "Sonnet 3.7 Region", description: "Region override for Claude 3.7 Sonnet in Vertex AI", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "VERTEX_REGION_CLAUDE_4_0_OPUS", shortName: "Opus 4.0 Region", description: "Region override for Claude 4.0 Opus in Vertex AI", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "VERTEX_REGION_CLAUDE_4_0_SONNET", shortName: "Sonnet 4.0 Region", description: "Region override for Claude 4.0 Sonnet in Vertex AI", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "VERTEX_REGION_CLAUDE_4_1_OPUS", shortName: "Opus 4.1 Region", description: "Region override for Claude 4.1 Opus in Vertex AI", type: .string, defaultValue: nil),

        // AWS Bedrock
        ClaudeEnvVariable(name: "AWS_BEARER_TOKEN_BEDROCK", shortName: "Bedrock Token", description: "Bedrock API key for authentication", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "AWS_REGION", shortName: "AWS Region", description: "AWS region", type: .string, defaultValue: nil),

        // Bash Configuration
        ClaudeEnvVariable(name: "BASH_DEFAULT_TIMEOUT_MS", shortName: "Bash Default Timeout", description: "Default timeout for long-running bash commands", type: .integer, defaultValue: nil),
        ClaudeEnvVariable(name: "BASH_MAX_OUTPUT_LENGTH", shortName: "Bash Max Output", description: "Maximum characters in bash outputs before truncation", type: .integer, defaultValue: nil),
        ClaudeEnvVariable(name: "BASH_MAX_TIMEOUT_MS", shortName: "Bash Max Timeout", description: "Maximum timeout the model can set for bash commands", type: .integer, defaultValue: nil),
        ClaudeEnvVariable(name: "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR", shortName: "Maintain Working Dir", description: "Return to original working directory after each Bash command", type: .boolean, defaultValue: "false"),

        // Claude Code Configuration
        ClaudeEnvVariable(name: "API_TIMEOUT_MS", shortName: "API Timeout", description: "API request timeout in milliseconds", type: .integer, defaultValue: nil),
        ClaudeEnvVariable(name: "CLAUDE_CODE_API_KEY_HELPER_TTL_MS", shortName: "Key Refresh Interval", description: "Credential refresh interval in milliseconds", type: .integer, defaultValue: nil),
        ClaudeEnvVariable(name: "CLAUDE_CODE_CLIENT_CERT", shortName: "Client Certificate", description: "Path to client certificate file for mTLS authentication", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "CLAUDE_CODE_CLIENT_KEY", shortName: "Client Key", description: "Path to client private key file for mTLS authentication", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "CLAUDE_CODE_CLIENT_KEY_PASSPHRASE", shortName: "Key Passphrase", description: "Passphrase for encrypted private key", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "CLAUDE_CODE_DISABLE_BACKGROUND_TASKS", shortName: "Disable Background Tasks", description: "Disable all background task functionality", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS", shortName: "Disable Betas", description: "Disable Anthropic API-specific beta headers", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC", shortName: "Disable Traffic", description: "Disable non-essential network traffic", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "CLAUDE_CODE_DISABLE_TERMINAL_TITLE", shortName: "Disable Terminal Title", description: "Disable automatic terminal title updates", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "CLAUDE_CODE_ENABLE_TELEMETRY", shortName: "Enable Telemetry", description: "Enable telemetry collection", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS", shortName: "File Read Max Tokens", description: "Override default token limit for file reads", type: .integer, defaultValue: nil),
        ClaudeEnvVariable(name: "CLAUDE_CODE_HIDE_ACCOUNT_INFO", shortName: "Hide Account Info", description: "Hide email and organization name from UI", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL", shortName: "Skip IDE Auto Install", description: "Skip auto-installation of IDE extensions", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "CLAUDE_CODE_MAX_OUTPUT_TOKENS", shortName: "Max Output Tokens", description: "Maximum output tokens for most requests", type: .integer, defaultValue: "4096"),
        ClaudeEnvVariable(name: "CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS", shortName: "OTEL Headers Interval", description: "Interval for refreshing dynamic OpenTelemetry headers", type: .integer, defaultValue: "1740000"),
        ClaudeEnvVariable(name: "CLAUDE_CODE_SHELL", shortName: "Shell Override", description: "Override automatic shell detection", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "CLAUDE_CODE_SHELL_PREFIX", shortName: "Shell Prefix", description: "Command prefix to wrap all bash commands", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "CLAUDE_CODE_SKIP_BEDROCK_AUTH", shortName: "Skip Bedrock Auth", description: "Skip AWS authentication for Bedrock", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "CLAUDE_CODE_SKIP_FOUNDRY_AUTH", shortName: "Skip Foundry Auth", description: "Skip Azure authentication for Microsoft Foundry", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "CLAUDE_CODE_SKIP_VERTEX_AUTH", shortName: "Skip Vertex Auth", description: "Skip Google authentication for Vertex", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "CLAUDE_CODE_USE_BEDROCK", shortName: "Use Bedrock", description: "Use Amazon Bedrock", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "CLAUDE_CODE_USE_FOUNDRY", shortName: "Use Foundry", description: "Use Microsoft Foundry", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "CLAUDE_CODE_USE_VERTEX", shortName: "Use Vertex", description: "Use Google Vertex AI", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "CLAUDE_CONFIG_DIR", shortName: "Config Directory", description: "Custom location for configuration and data files", type: .string, defaultValue: "~/.claude"),
        ClaudeEnvVariable(name: "CLAUDE_ENV_FILE", shortName: "Env File Path", description: "File path for persisting environment variables from SessionStart hooks", type: .string, defaultValue: nil),

        // Feature Toggles
        ClaudeEnvVariable(name: "DISABLE_AUTOUPDATER", shortName: "Disable Auto Update", description: "Disable automatic updates", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "DISABLE_BUG_COMMAND", shortName: "Disable Bug Command", description: "Disable /bug command", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "DISABLE_COST_WARNINGS", shortName: "Disable Cost Warnings", description: "Disable cost warning messages", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "DISABLE_ERROR_REPORTING", shortName: "Disable Error Report", description: "Opt out of Sentry error reporting", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "DISABLE_NON_ESSENTIAL_MODEL_CALLS", shortName: "Disable Extra Calls", description: "Disable model calls for non-critical paths", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "DISABLE_PROMPT_CACHING", shortName: "Disable Caching", description: "Disable prompt caching for all models", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "DISABLE_PROMPT_CACHING_HAIKU", shortName: "Disable Haiku Cache", description: "Disable prompt caching for Haiku models", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "DISABLE_PROMPT_CACHING_OPUS", shortName: "Disable Opus Cache", description: "Disable prompt caching for Opus models", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "DISABLE_PROMPT_CACHING_SONNET", shortName: "Disable Sonnet Cache", description: "Disable prompt caching for Sonnet models", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "DISABLE_TELEMETRY", shortName: "Disable Telemetry", description: "Opt out of Statsig telemetry", type: .boolean, defaultValue: "false"),

        // Proxy Configuration
        ClaudeEnvVariable(name: "HTTP_PROXY", shortName: "HTTP Proxy", description: "HTTP proxy server", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "HTTPS_PROXY", shortName: "HTTPS Proxy", description: "HTTPS proxy server", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "NO_PROXY", shortName: "Proxy Bypass", description: "List of domains and IPs to bypass proxy", type: .string, defaultValue: nil),

        // MCP Configuration
        ClaudeEnvVariable(name: "MAX_MCP_OUTPUT_TOKENS", shortName: "MCP Max Tokens", description: "Maximum tokens for MCP tool responses", type: .integer, defaultValue: "25000"),
        ClaudeEnvVariable(name: "MCP_TIMEOUT", shortName: "MCP Startup Timeout", description: "Timeout in milliseconds for MCP server startup", type: .integer, defaultValue: nil),
        ClaudeEnvVariable(name: "MCP_TOOL_TIMEOUT", shortName: "MCP Tool Timeout", description: "Timeout in milliseconds for MCP tool execution", type: .integer, defaultValue: nil),

        // Thinking Configuration
        ClaudeEnvVariable(name: "MAX_THINKING_TOKENS", shortName: "Thinking Tokens", description: "Token budget for extended thinking process", type: .integer, defaultValue: "0"),

        // Certificate Configuration
        ClaudeEnvVariable(name: "NODE_EXTRA_CA_CERTS", shortName: "CA Certificates", description: "Path to custom CA certificates", type: .string, defaultValue: nil),

        // OpenTelemetry Configuration
        ClaudeEnvVariable(name: "OTEL_EXPORTER_OTLP_ENDPOINT", shortName: "OTLP Endpoint", description: "OTLP collector endpoint", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "OTEL_EXPORTER_OTLP_HEADERS", shortName: "OTLP Headers", description: "OTLP authentication headers", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "OTEL_EXPORTER_OTLP_LOGS_ENDPOINT", shortName: "OTLP Logs Endpoint", description: "OTLP logs endpoint", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "OTEL_EXPORTER_OTLP_LOGS_PROTOCOL", shortName: "OTLP Logs Protocol", description: "Logs protocol", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "OTEL_EXPORTER_OTLP_METRICS_ENDPOINT", shortName: "OTLP Metrics Endpoint", description: "OTLP metrics endpoint", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "OTEL_EXPORTER_OTLP_METRICS_PROTOCOL", shortName: "OTLP Metrics Protocol", description: "Metrics protocol", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "OTEL_EXPORTER_OTLP_PROTOCOL", shortName: "OTLP Protocol", description: "OTLP exporter protocol", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "OTEL_LOG_USER_PROMPTS", shortName: "Log User Prompts", description: "Enable logging of user prompt content", type: .boolean, defaultValue: "false"),
        ClaudeEnvVariable(name: "OTEL_LOGS_EXPORTER", shortName: "Logs Exporter", description: "Logs exporter type", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "OTEL_LOGS_EXPORT_INTERVAL", shortName: "Logs Export Interval", description: "Logs export interval in milliseconds", type: .integer, defaultValue: "5000"),
        ClaudeEnvVariable(name: "OTEL_METRIC_EXPORT_INTERVAL", shortName: "Metrics Export Interval", description: "Metrics export interval in milliseconds", type: .integer, defaultValue: "60000"),
        ClaudeEnvVariable(name: "OTEL_METRICS_EXPORTER", shortName: "Metrics Exporter", description: "Metrics exporter type", type: .string, defaultValue: nil),
        ClaudeEnvVariable(name: "OTEL_METRICS_INCLUDE_ACCOUNT_UUID", shortName: "Include Account UUID", description: "Include account UUID attribute in metrics", type: .boolean, defaultValue: "true"),
        ClaudeEnvVariable(name: "OTEL_METRICS_INCLUDE_SESSION_ID", shortName: "Include Session ID", description: "Include session ID attribute in metrics", type: .boolean, defaultValue: "true"),
        ClaudeEnvVariable(name: "OTEL_METRICS_INCLUDE_VERSION", shortName: "Include Version", description: "Include version attribute in metrics", type: .boolean, defaultValue: "false"),

        // Miscellaneous
        ClaudeEnvVariable(name: "SLASH_COMMAND_TOOL_CHAR_BUDGET", shortName: "Command Char Budget", description: "Maximum characters for slash command metadata", type: .integer, defaultValue: "15000"),
        ClaudeEnvVariable(name: "USE_BUILTIN_RIPGREP", shortName: "Use Built-in RipGrep", description: "Use built-in rg instead of system-installed rg", type: .boolean, defaultValue: "true"),
    ]

    /// Get a variable by name
    static func find(byName name: String) -> ClaudeEnvVariable? {
        allVariables.first { $0.name == name }
    }

    /// Filter variables by search query
    static func search(_ query: String) -> [ClaudeEnvVariable] {
        guard !query.isEmpty else { return allVariables }
        let lowercasedQuery = query.lowercased()
        return allVariables.filter {
            $0.name.lowercased().contains(lowercasedQuery) ||
            $0.descriptionDefault.lowercased().contains(lowercasedQuery)
        }
    }

    /// Get available variables excluding already configured ones
    static func availableVariables(excluding existingKeys: Set<String>) -> [ClaudeEnvVariable] {
        allVariables.filter { !existingKeys.contains($0.name) }
    }
}
