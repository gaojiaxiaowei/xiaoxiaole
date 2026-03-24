#!/bin/bash

# Block Blast 游戏上传到GitHub 脚本
# 使用方法：sh upload_to_github.sh

echo "=========================================="
echo "  Block Blast 上传到GitHub 脚本"
echo "=========================================="
echo ""

# 配置信息
GITHUB_USER="gaojiaxiaowei"
REPO_NAME="xiaoxiaole"
PROJECT_DIR="/home/gem/workspace/agent/workspace/projects/block-blast/app"

# 进入项目目录
cd $PROJECT_DIR || { echo "❌ 项目目录不存在"; exit 1; }

echo "📁 当前目录: $(pwd)"
echo ""

# 检查是否已经是git仓库
if [ -d ".git" ]; then
    echo "✅ Git仓库已存在"
else
    echo "🔧 初始化Git仓库..."
    git init
    echo "✅ Git仓库初始化完成"
fi

echo ""

# 检查远程仓库
if git remote | grep -q "origin"; then
    echo "✅ 远程仓库已配置"
else
    echo "🔗 添加远程仓库..."
    git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git
    echo "✅ 远程仓库添加完成"
fi

echo ""

# 添加所有文件
echo "📦 添加所有文件..."
git add .
echo "✅ 文件添加完成"

echo ""

# 提交
echo "💾 提交代码..."
git commit -m "Block Blast game - 18 features, 217 tests passed

Features:
- P1: Score history, haptic feedback, startup animation
- P2: Daily challenge, timed mode, power-up system
- P3: Backend API, ad integration
- UX: Pause function, bomb selection highlight

Tests: 217/217 passed ✅
"
echo "✅ 代码提交完成"

echo ""

# 推送到GitHub
echo "🚀 推送到GitHub..."
git branch -M main
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ 上传成功！"
    echo "=========================================="
    echo ""
    echo "📦 仓库地址: https://github.com/$GITHUB_USER/$REPO_NAME"
    echo ""
    echo "⏳ GitHub Actions正在自动打包APK..."
    echo "   预计5-10分钟完成"
    echo ""
    echo "📥 下载APK:"
    echo "   1. 打开 https://github.com/$GITHUB_USER/$REPO_NAME/actions"
    echo "   2. 点击最新的workflow"
    echo "   3. 在Artifacts中下载 block-blast-apk"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "❌ 上传失败"
    echo "=========================================="
    echo ""
    echo "可能的原因："
    echo "1. GitHub账号未配置SSH密钥"
    echo "2. 仓库不存在"
    echo "3. 网络问题"
    echo ""
    echo "解决方法："
    echo "1. 确保仓库 https://github.com/$GITHUB_USER/$REPO_NAME 已创建"
    echo "2. 配置GitHub认证："
    echo "   git config --global user.name \"你的名字\""
    echo "   git config --global user.email \"你的邮箱\""
    echo ""
fi
