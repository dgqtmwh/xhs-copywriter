import SwiftUI

struct ContentView: View {
    @StateObject private var vm = CopywriterViewModel()
    @FocusState private var focused: Bool
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { scroll in
                ScrollView {
                    VStack(spacing: 16) {
                        inputCard
                        stylePicker
                        generateButton
                        
                        if !vm.resultText.isEmpty {
                            resultCard
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .id("result")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemGray6).ignoresSafeArea())
                .navigationTitle("红书文案")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if !vm.resultText.isEmpty {
                            Button("清空") { withAnimation { vm.clear() } }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onTapGesture { focused = false }
                .onChange(of: vm.resultText) { _, _ in
                    withAnimation { scroll.scrollTo("result", anchor: .top) }
                }
            }
        }
    }
    
    // MARK: - 输入卡片
    
    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.accentColor)
                Text("写什么？")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if !vm.inputText.isEmpty {
                    Text("\(vm.inputText.count)")
                        .font(.caption)
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
            
            TextEditor(text: $vm.inputText)
                .focused($focused)
                .frame(height: 88)
                .padding(10)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(focused ? Color.accentColor : Color(.separator), lineWidth: focused ? 1.5 : 0.5)
                )
                .overlay(alignment: .topLeading) {
                    if vm.inputText.isEmpty {
                        Text("产品名、关键词、一句话描述...")
                            .foregroundColor(Color(.tertiaryLabel))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .allowsHitTesting(false)
                    }
                }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    // MARK: - 风格选择
    
    private var stylePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "textformat")
                    .foregroundColor(.accentColor)
                Text("风格")
                    .font(.subheadline.weight(.semibold))
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(WritingStyle.allCases, id: \.self) { style in
                    styleCard(style)
                }
            }
        }
    }
    
    private func styleCard(_ style: WritingStyle) -> some View {
        let selected = vm.selectedStyle == style
        
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(duration: 0.25)) {
                vm.selectedStyle = style
            }
        } label: {
            VStack(spacing: 4) {
                Text(style.icon)
                    .font(.title2)
                Text(style.displayName)
                    .font(.subheadline.weight(.medium))
                Text(style.description)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selected ? Color.accentColor : Color(.systemBackground))
            .foregroundColor(selected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? Color.clear : Color(.separator), lineWidth: 0.5)
            )
        }
    }
    
    // MARK: - 生成按钮
    
    private var generateButton: some View {
        Button {
            focused = false
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            Task { await vm.generate() }
        } label: {
            HStack(spacing: 8) {
                if vm.isGenerating {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.85)
                    Text("生成中...")
                        .font(.headline)
                } else {
                    Image(systemName: "sparkles")
                    Text("生成文案")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(vm.inputText.isEmpty ? Color.accentColor.opacity(0.35) : Color.accentColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(vm.inputText.isEmpty || vm.isGenerating)
    }
    
    // MARK: - 结果卡片
    
    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.accentColor)
                    .font(.caption)
                Text("\(vm.selectedStyle.displayName)文案")
                    .font(.subheadline.weight(.semibold))
                
                Spacer()
                
                Button {
                    UIPasteboard.general.string = vm.resultText
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    vm.copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        vm.copied = false
                    }
                } label: {
                    Label(vm.copied ? "已复制" : "复制", systemImage: vm.copied ? "checkmark.circle.fill" : "doc.on.doc")
                        .font(.caption)
                        .foregroundColor(vm.copied ? .green : .accentColor)
                }
                
                Button {
                    Task { await vm.generate() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
                .disabled(vm.isGenerating)
            }
            
            Divider()
            
            Text(vm.resultText)
                .font(.body)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - WritingStyle 扩展

extension WritingStyle {
    var icon: String {
        switch self {
        case .zhongcao: return "🛍️"
        case .ganhuo: return "📚"
        case .qingxu: return "💭"
        case .ceping: return "🔍"
        }
    }
    
    var description: String {
        switch self {
        case .zhongcao: return "好物安利"
        case .ganhuo: return "知识分享"
        case .qingxu: return "走心故事"
        case .ceping: return "客观对比"
        }
    }
}

// MARK: - ViewModel

@MainActor
class CopywriterViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var selectedStyle: WritingStyle = .zhongcao
    @Published var resultText = ""
    @Published var isGenerating = false
    @Published var copied = false
    
    private let ai = AIService.shared
    
    func generate() async {
        guard !inputText.isEmpty else { return }
        isGenerating = true
        resultText = ""
        let r = await ai.generateCopy(for: inputText, style: selectedStyle)
        resultText = r
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
