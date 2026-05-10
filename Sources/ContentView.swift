import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CopywriterViewModel()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 头部
                    headerView
                    
                    // 输入区
                    inputSection
                    
                    // 风格选择
                    styleSection
                    
                    // 生成按钮
                    generateButton
                    
                    // 结果区
                    resultSection
                }
                .padding()
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("红书文案")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("清空") {
                        viewModel.clear()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                isInputFocused = false
            }
        }
    }
    
    // MARK: - 头部
    
    private var headerView: some View {
        VStack(spacing: 6) {
            Text("AI 小红书文案生成器")
                .font(.title3.weight(.semibold))
            Text("输入关键词，一键生成种草/干货/情绪文案")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - 输入区
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("产品 / 关键词")
                .font(.subheadline.weight(.semibold))
            
            TextEditor(text: $viewModel.inputText)
                .focused($isInputFocused)
                .frame(height: 100)
                .padding(12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
                .overlay(alignment: .topLeading) {
                    if viewModel.inputText.isEmpty {
                        Text("例如：一款平价防晒霜、周末去哪玩、...")
                            .foregroundColor(.tertiary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
    
    // MARK: - 风格选择
    
    private var styleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("文案风格")
                .font(.subheadline.weight(.semibold))
            
            HStack(spacing: 8) {
                ForEach(WritingStyle.allCases, id: \.self) { style in
                    styleButton(style)
                }
            }
        }
    }
    
    private func styleButton(_ style: WritingStyle) -> some View {
        Button {
            viewModel.selectedStyle = style
        } label: {
            Text(style.rawValue)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    viewModel.selectedStyle == style
                        ? Color.accentColor
                        : Color(.systemBackground)
                )
                .foregroundColor(
                    viewModel.selectedStyle == style
                        ? .white
                        : .primary
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
        }
    }
    
    // MARK: - 生成按钮
    
    private var generateButton: some View {
        Button {
            Task {
                await viewModel.generate()
            }
        } label: {
            HStack(spacing: 8) {
                if viewModel.isGenerating {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                }
                Text(viewModel.isGenerating ? "生成中..." : "✨ 生成文案")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                viewModel.inputText.isEmpty
                    ? Color.accentColor.opacity(0.4)
                    : Color.accentColor
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(viewModel.inputText.isEmpty || viewModel.isGenerating)
    }
    
    // MARK: - 结果区
    
    @ViewBuilder
    private var resultSection: some View {
        if !viewModel.resultText.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                // 结果头部
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.accentColor)
                    Text("生成结果")
                        .font(.subheadline.weight(.semibold))
                    
                    Spacer()
                    
                    // 复制按钮
                    Button {
                        UIPasteboard.general.string = viewModel.resultText
                        viewModel.copied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            viewModel.copied = false
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: viewModel.copied ? "checkmark" : "doc.on.doc")
                                .font(.caption)
                            Text(viewModel.copied ? "已复制" : "复制")
                                .font(.subheadline)
                        }
                        .foregroundColor(viewModel.copied ? .green : .accentColor)
                    }
                    
                    // 重新生成
                    Button {
                        Task { await viewModel.generate() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.accentColor)
                    }
                }
                
                // 文案内容
                Text(viewModel.resultText)
                    .font(.body)
                    .lineSpacing(6)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
class CopywriterViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var selectedStyle: WritingStyle = .种草
    @Published var resultText = ""
    @Published var isGenerating = false
    @Published var copied = false
    
    private let aiService = AIService.shared
    
    func generate() async {
        guard !inputText.isEmpty else { return }
        
        isGenerating = true
        resultText = ""
        
        let result = await aiService.generateCopy(for: inputText, style: selectedStyle)
        
        resultText = result
        isGenerating = false
    }
    
    func clear() {
        inputText = ""
        resultText = ""
        copied = false
    }
}

#Preview {
    ContentView()
}
