#!/bin/bash
set -euo pipefail

echo "🚀 红书文案 - 一键 Setup"
echo "========================"

# 1. Homebrew
if ! command -v brew &>/dev/null; then
    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo "🍺 安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi
echo "✅ Homebrew 已就绪"

# 2. XcodeGen
if ! command -v xcodegen &>/dev/null; then
    echo "📦 安装 XcodeGen..."
    brew install xcodegen
fi
echo "✅ XcodeGen 已就绪"

# 3. 生成 Xcode 项目
echo "🔧 生成 Xcode 项目..."
xcodegen generate
echo "✅ 项目已生成"

# 4. 打开 Xcode
echo "📱 打开 Xcode..."
open XHSCopywriter.xcodeproj

echo ""
echo "🎉 完成！选 iOS 26+ Simulator → Cmd+R"
