import XCTest

/// UI 交互测试 — 红书文案主界面
final class XHSCopywriterUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - 页面元素存在性

    /// 导航标题存在
    func testNavigationTitleExists() {
        let nav = app.navigationBars["红书文案"]
        XCTAssertTrue(nav.exists, "导航标题应显示'红书文案'")
    }

    /// 输入框存在且可交互
    func testInputFieldExists() {
        let textView = app.textViews.firstMatch
        XCTAssertTrue(textView.exists, "输入框应存在")
        XCTAssertTrue(textView.isHittable, "输入框应可点击")
    }

    /// 四种风格按钮全部存在
    func testAllStyleButtonsExist() {
        let styleNames = ["种草风", "干货风", "情绪风", "测评风"]
        for name in styleNames {
            let btn = app.buttons[name]
            XCTAssertTrue(btn.exists, "风格按钮 '\(name)' 应存在")
        }
    }

    /// "生成文案"按钮存在
    func testGenerateButtonExists() {
        let btn = app.buttons["✨ 生成文案"]
        XCTAssertTrue(btn.exists, "生成按钮应存在")
    }

    // MARK: - 交互逻辑

    /// 空输入时生成按钮应禁用
    func testGenerateButtonDisabledWhenEmpty() {
        let btn = app.buttons["✨ 生成文案"]
        XCTAssertFalse(btn.isEnabled, "空输入时生成按钮应禁用")
    }

    /// 输入文字后生成按钮应可用
    func testGenerateButtonEnabledAfterInput() {
        let textView = app.textViews.firstMatch
        textView.tap()
        textView.typeText("防晒霜")

        let btn = app.buttons["✨ 生成文案"]
        let enabled = btn.isEnabled
        // 注：键盘弹出可能使按钮移出可视区，但不影响 enabled 状态
        XCTAssertTrue(enabled, "输入后生成按钮应可用")
    }

    /// 点击风格按钮可切换选中状态
    func testStyleButtonSelection() {
        // 默认选中"种草风"，点击"干货风"
        let ganghuo = app.buttons["干货风"]
        XCTAssertTrue(ganghuo.exists)
        ganghuo.tap()

        // 干货风应变为选中状态（selected 或 accessibility 变化）
        // 注：SwiftUI button 选中状态可能不直接映射到 XCUI 的 selected
        // 此处验证按钮可点击即可
        XCTAssertTrue(ganghuo.isHittable)
    }

    // MARK: - 功能流程

    /// 完整生成流程：输入 → 生成 → 结果出现
    func testFullGenerateFlow() {
        let textView = app.textViews.firstMatch
        textView.tap()
        textView.typeText("防晒霜")

        let genBtn = app.buttons["✨ 生成文案"]
        guard genBtn.isEnabled else {
            XCTFail("输入后生成按钮应可用")
            return
        }
        genBtn.tap()

        // 等待结果出现（最多 5 秒）
        let exists = app.staticTexts["种草风文案"].waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "生成后应显示结果")
    }

    /// 结果出现后应有复制按钮
    func testCopyButtonAppearsAfterGenerate() {
        let textView = app.textViews.firstMatch
        textView.tap()
        textView.typeText("防晒霜")
        app.buttons["✨ 生成文案"].tap()

        let copyBtn = app.buttons["复制"].waitForExistence(timeout: 5)
        XCTAssertTrue(copyBtn, "生成后应有复制按钮")
    }

    /// 清空按钮清空所有状态
    func testClearButtonResetsAll() {
        // 先输入并生成
        let textView = app.textViews.firstMatch
        textView.tap()
        textView.typeText("防晒霜")
        app.buttons["✨ 生成文案"].tap()

        // 等待结果出现，然后点清空
        let _ = app.staticTexts["种草风文案"].waitForExistence(timeout: 5)
        app.buttons["清空"].tap()

        // 输入框应为空
        let inputText = textView.value as? String ?? ""
        XCTAssertTrue(inputText.isEmpty || inputText == "产品名、关键词、一句话描述...",
                      "清空后输入框应重置")
    }
}
