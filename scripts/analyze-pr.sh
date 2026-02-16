#!/bin/bash
set -e

PR_NUMBER=$1
if [ -z "$PR_NUMBER" ]; then
    echo "Usage: $0 <PR_NUMBER>"
    echo "Example: $0 2"
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo "❌ Error: 'gh' (GitHub CLI) is not installed."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ Error: 'jq' is not installed. Install with: brew install jq"
    exit 1
fi

echo "📊 Analyzing PR #$PR_NUMBER..."
echo ""

# 获取 PR 信息
PR_INFO=$(gh pr view $PR_NUMBER --json title,body,author,files,additions,deletions)
PR_TITLE=$(echo "$PR_INFO" | jq -r '.title')
PR_AUTHOR=$(echo "$PR_INFO" | jq -r '.author.login')
PR_AUTHOR_NAME=$(echo "$PR_INFO" | jq -r '.author.name // .author.login')
PR_BODY=$(echo "$PR_INFO" | jq -r '.body // "No description provided"')
PR_ADDITIONS=$(echo "$PR_INFO" | jq -r '.additions')
PR_DELETIONS=$(echo "$PR_INFO" | jq -r '.deletions')

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 PR #$PR_NUMBER: $PR_TITLE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👤 Author: @$PR_AUTHOR ($PR_AUTHOR_NAME)"
echo "📊 Changes: +$PR_ADDITIONS / -$PR_DELETIONS lines"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Description:"
echo "$PR_BODY"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 获取修改的文件并推断 Scope
echo "📁 Modified Files:"
FILES=$(echo "$PR_INFO" | jq -r '.files[].path')
echo "$FILES"
echo ""

# 智能推断 Scope 和 Category
SCOPE="TODO"
CATEGORY="TODO"

if echo "$FILES" | grep -q "Sources/MarkdownPreview/"; then
    SCOPE="QuickLook"
fi

if echo "$FILES" | grep -q "Sources/Markdown/"; then
    SCOPE="App"
fi

if echo "$FILES" | grep -q "web-renderer/"; then
    SCOPE="渲染器 (Renderer)"
fi

if echo "$FILES" | grep -q "Makefile\|project.yml\|scripts/"; then
    SCOPE="构建系统 (Build)"
fi

if echo "$PR_TITLE" | grep -qi "fix\|bug\|修复"; then
    CATEGORY="Fixed"
elif echo "$PR_TITLE" | grep -qi "add\|feat\|新增"; then
    CATEGORY="Added"
elif echo "$PR_TITLE" | grep -qi "update\|improve\|优化\|改进"; then
    CATEGORY="Changed"
elif echo "$PR_TITLE" | grep -qi "remove\|delete\|删除"; then
    CATEGORY="Removed"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Code Changes:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
gh pr diff $PR_NUMBER | head -n 200
echo ""

if [ $(gh pr diff $PR_NUMBER | wc -l) -gt 200 ]; then
    echo "... (diff truncated, showing first 200 lines)"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Suggested CHANGELOG Entry:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "### $CATEGORY"
echo "- **$SCOPE**: $PR_TITLE。（感谢 [@$PR_AUTHOR](https://github.com/$PR_AUTHOR) 的贡献 [#$PR_NUMBER](https://github.com/xykong/flux-markdown/pull/$PR_NUMBER)）"
echo "  - [TODO: 分析代码变更，填写技术实现细节 1]"
echo "  - [TODO: 技术实现细节 2]"
echo "  - [TODO: 技术实现细节 3]"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Next Steps:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. 根据上述代码变更，完善技术实现细节"
echo "2. 将生成的条目添加到 CHANGELOG.md 的 [Unreleased] 部分"
echo "3. 执行以下命令提交："
echo ""
echo "   vim CHANGELOG.md"
echo "   git add CHANGELOG.md"
echo "   git commit -m 'docs(changelog): add PR #$PR_NUMBER to unreleased section'"
echo "   git push origin master"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
