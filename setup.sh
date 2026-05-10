#!/bin/bash
set -euo pipefail

echo "🚀 红书文案 - 一键 Setup"
echo "========================"

# 1. XcodeGen
if ! command -v xcodegen &>/dev/null; then
    echo "📦 安装 XcodeGen..."
    brew install xcodegen
fi
echo "✅ XcodeGen 已就绪"

# 2. 生成 Xcode 项目
echo "🔧 生成 Xcode 项目..."
xcodegen generate
echo "✅ 项目已生成"

# 3. 打开 Xcode
echo "📱 打开 Xcode..."
open XHSCopywriter.xcodeproj

echo ""
echo "🎉 完成！选 iOS 26+ Simulator → Cmd+R"
