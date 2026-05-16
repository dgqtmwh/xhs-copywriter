import XCTest
@testable import XHSCopywriter

/// Service 层测试 — AIService 文案生成逻辑
final class AIServiceTests: XCTestCase {

    private let ai = AIService.shared

    // MARK: - 输入验证

    /// 空输入应返回提示文案
    func testGenerateWithEmptyInput_ReturnsPrompt() async {
        let result = await ai.generateCopy(for: "", style: .zhongcao)
        XCTAssertTrue(result.contains("请输入"))
        XCTAssertFalse(result.isEmpty)
    }

    /// 纯空格输入也应返回提示
    func testGenerateWithWhitespaceInput_ReturnsPrompt() async {
        let result = await ai.generateCopy(for: "   ", style: .ganhuo)
        XCTAssertTrue(result.contains("请输入"))
    }

    // MARK: - 四种风格输出

    /// 种草风：包含 emoji 和话题标签
    func testGenerate_种草_ContainsHashtags() async {
        let result = await ai.generateCopy(for: "防晒霜", style: .zhongcao)
        XCTAssertTrue(result.contains("#"), "种草文案应包含话题标签")
        XCTAssertTrue(result.contains("姐妹们"), "种草文案应以姐妹开头")
    }

    /// 干货风：包含数字序号
    func testGenerate_干货_ContainsBullets() async {
        let result = await ai.generateCopy(for: "Python入门", style: .ganhuo)
        XCTAssertTrue(result.contains("📌"), "干货文案应包含要点标记")
        XCTAssertTrue(result.contains("真相"), "干货文案应包含'真相'")
    }

    /// 情绪风：包含情感关键词
    func testGenerate_情绪_ContainsEmotion() async {
        let result = await ai.generateCopy(for: "远距离恋爱", style: .qingxu)
        XCTAssertTrue(result.contains("缘分") || result.contains("生活") || result.contains("小确幸"),
                      "情绪文案应包含感性词汇")
    }

    /// 测评风：包含优缺点结构
    func testGenerate_测评_HasProsAndCons() async {
        let result = await ai.generateCopy(for: "AirPods Pro", style: .ceping)
        XCTAssertTrue(result.contains("✅"), "测评文案应包含优点")
        XCTAssertTrue(result.contains("❌"), "测评文案应包含缺点")
    }

    // MARK: - 不同输入产生差异化输出

    /// 不同输入应该生成包含不同关键词的结果
    func testGenerate_DifferentInput_DifferentKeyword() async {
        let resultA = await ai.generateCopy(for: "防晒霜", style: .zhongcao)
        let resultB = await ai.generateCopy(for: "洗面奶", style: .zhongcao)

        XCTAssertTrue(resultA.contains("防晒"), "A 应包含防晒")
        XCTAssertTrue(resultB.contains("洗面"), "B 应包含洗面")
    }

    // MARK: - 风格枚举

    /// 所有风格都有非空的 prompt instruction
    func testAllStylesHaveNonEmptyPrompt() {
        for style in WritingStyle.allCases {
            XCTAssertFalse(style.promptInstruction.isEmpty, "\(style.rawValue) 应有 prompt")
        }
    }

    /// 四种风格齐全
    func testWritingStyleCount() {
        XCTAssertEqual(WritingStyle.allCases.count, 4)
    }
}
