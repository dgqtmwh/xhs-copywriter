import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

/// AI 服务 — 使用 Apple Foundation Models 生成小红书文案
actor AIService {
    static let shared = AIService()
    
    private var modelAvailable = false
    
    func checkAvailability() -> Bool {
        if #available(iOS 26, *) {
            modelAvailable = true
            return true
        }
        modelAvailable = false
        return false
    }
    
    /// 生成小红书文案
    func generateCopy(for input: String, style: WritingStyle) async -> String {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "请输入关键词或产品描述 ✍️"
        }
        
        let prompt = """
        你是一个专业的小红书文案写手。
        
        \(style.promptInstruction)
        
        请根据以下关键词/描述写一篇小红书文案：
        \(input)
        """
        
        if #available(iOS 26, *) {
            return await foundationModelsGenerate(prompt: prompt, input: input, style: style)
        } else {
            return fallbackGenerate(input: input, style: style)
        }
    }
    
    // MARK: - Foundation Models (iOS 26+)
    
    @available(iOS 26, *)
    private func foundationModelsGenerate(prompt: String, input: String, style: WritingStyle) async -> String {
        #if canImport(FoundationModels)
        do {
            let model = FMGenerativeModel(
                configuration: .init(model: .appleFoundation)
            )
            let result = try await model.generateContent(prompt)
            return result.text
        } catch {
            return fallbackGenerate(input: input, style: style)
        }
        #else
        return fallbackGenerate(input: input, style: style)
        #endif
    }
    
    // MARK: - 降级方案（离线规则生成）
    
    private func fallbackGenerate(input: String, style: WritingStyle) -> String {
        switch style {
        case .zhongcao:
            return """
            姐妹们！发现了一个宝藏，迫不及待来分享 🎉
            
            最近一直在用的\(input)，真的绝绝子！一开始是朋友推荐的，用了之后直接爱上。
            
            ✨ 使用感受：
            整体体验非常棒，细节处理很到位。每天用了之后心情都变好了，强烈推荐给每一个需要的姐妹！
            
            💡 小tips：
            建议刚开始可以先试试基础款，不会踩雷～
            
            真心安利，入股不亏！🔥
            
            #好物分享 #\(input) #宝藏推荐 #入手不亏 #真实体验
            """
        case .ganhuo:
            return """
            【关于 \(input)，你可能不知道的 3 个真相】
            
            最近很多人在问\(input)相关的问题，今天一次性说清楚👇
            
            📌 第一点
            选择\(input)时，核心要看这几个指标。很多人第一步就选错了，后面全白费。
            
            📌 第二点
            使用\(input)的最佳方式并不是大家想的那样。正确的做法是...
            
            📌 第三点
            避坑提醒！这几个雷区千万别踩，我已经帮你们试过了。
            
            觉得有用的点赞收藏，下次需要时直接翻出来看！
            
            #干货分享 #\(input) #知识科普 #避坑指南 #实用技巧
            """
        case .qingxu:
            return """
            今天想聊聊 \(input)
            
            说起来，跟\(input)的缘分还挺奇妙的。
            
            一开始并没有期待太多，但真正接触之后才发现，原来生活还可以是这样。
            
            有时候觉得，我们总是在追逐远方的风景，却忽略了身边这些实实在在的美好。不需要多复杂，简简单单就很好。
            
            希望每个人都能找到属于自己的那份小确幸 🌙
            
            #心情日记 #\(input) #生活感悟 #温暖日常 #随记
            """
        case .ceping:
            return """
            🔍 \(input) 真实测评｜不吹不黑
            
            最近\(input)风很大，我自费买回来测了一周，今天交作业👇
            
            ✅ 优点
            1. 整体品质对得起这个价格
            2. 使用体验比较流畅
            3. 细节设计用心
            
            ❌ 缺点
            1. 部分功能还有优化空间
            2. 初次上手需要适应期
            3. 性价比中上水平
            
            🎯 适合人群
            - 追求性价比的可以入
            - 对品质有要求但预算有限的首选
            - 不建议盲目跟风，按需购买
            
            ⭐ 综合评分：7.5/10
            
            #真实测评 #\(input) #开箱测评 #好物测评 #不吹不黑
            """
        }
    }
}
