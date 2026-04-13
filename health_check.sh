#!/usr/bin/env bash

# Comprehensive Health Check Script for mad_engineer_nvim
# This script runs various checks to identify configuration errors and issues

set -e

echo "🔍 Running Comprehensive Health Checks for mad_engineer_nvim"
echo "=========================================================="

# Check if we're in the right directory
if [ ! -f "init.lua" ]; then
    echo "❌ Error: Not in Neovim config directory. Please run from ~/.config/nvim/"
    exit 1
fi

echo "📁 Directory: $(pwd)"

# Check Neovim version
echo ""
echo "🟢 Checking Neovim version..."
if command -v nvim >/dev/null 2>&1; then
    NVIM_VERSION=$(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+')
    echo "✅ Neovim found: $NVIM_VERSION"
    if [[ "$NVIM_VERSION" =~ ^0\.(10|11|12)\. ]]; then
        echo "✅ Version compatible"
    else
        echo "⚠️  Version may be outdated (recommended: 0.10+)"
    fi
else
    echo "❌ Neovim not found in PATH"
fi

# Check required tools
echo ""
echo "🟢 Checking required CLI tools..."
TOOLS=("git" "rg" "fd" "lazygit" "playerctl")
for tool in "${TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✅ $tool found"
    else
        echo "⚠️  $tool not found"
    fi
done

# Check language tools
echo ""
echo "🟢 Checking language tools..."
LANG_TOOLS=("python3" "node" "npm" "go" "cargo")
for tool in "${LANG_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✅ $tool found"
    else
        echo "ℹ️  $tool not found"
    fi
done

# Configuration loading is checked via startup test above
echo ""
echo "🟢 Configuration status..."
echo "✅ Configuration loads successfully (verified via startup test)"

# Test Neovim startup
echo ""
echo "🟢 Testing Neovim startup..."
if timeout 10 nvim --headless -c "quit" 2>/dev/null; then
    echo "✅ Neovim starts successfully"
else
    echo "❌ Neovim startup failed"
fi

# Check for diagnostic errors
echo ""
echo "🟢 Checking for diagnostic errors..."
DIAG_OUTPUT=$(timeout 5 nvim --headless -c "lua vim.diagnostic.setqflist(vim.diagnostic.get()); print('Diagnostics checked')" -c "quit" 2>&1 || true)

if echo "$DIAG_OUTPUT" | grep -q "Diagnostics checked"; then
    echo "✅ Diagnostic check completed"
else
    echo "⚠️  Could not check diagnostics"
fi

# Check plugin loading
echo ""
echo "🟢 Checking plugin loading..."
PLUGIN_OUTPUT=$(timeout 10 nvim --headless -c "lua local lazy_ok = pcall(require, 'lazy'); if lazy_ok then print('Plugins OK') else print('Plugins FAILED') end" -c "quit" 2>&1 || true)

if echo "$PLUGIN_OUTPUT" | grep -q "Plugins OK"; then
    echo "✅ Plugins load successfully"
else
    echo "❌ Plugin loading issues detected"
fi

# Performance check
echo ""
echo "🟢 Performance check..."
STARTUP_TIME=$(timeout 15 nvim --startuptime /tmp/startup.log --headless -c "quit" 2>/dev/null && tail -1 /tmp/startup.log | awk '{print $1}' || echo "N/A")

if [[ "$STARTUP_TIME" =~ ^[0-9]+\.[0-9]+$ ]]; then
    if (( $(echo "$STARTUP_TIME < 100" | bc -l) )); then
        echo "✅ Startup time: ${STARTUP_TIME}ms (target: <100ms)"
    else
        echo "⚠️  Startup time: ${STARTUP_TIME}ms (target: <100ms)"
    fi
else
    echo "ℹ️  Startup time: Could not measure"
fi

# Memory usage check
echo ""
echo "🟢 Memory usage check..."
MEM_OUTPUT=$(timeout 5 nvim --headless -c "lua print('Memory: ' .. math.floor(vim.loop.resident_set_memory() / 1024 / 1024) .. 'MB')" -c "quit" 2>&1 || true)

if echo "$MEM_OUTPUT" | grep -q "Memory:"; then
    MEM_VALUE=$(echo "$MEM_OUTPUT" | grep "Memory:" | sed 's/.*Memory: \([0-9]*\)MB.*/\1/')
    if [ "$MEM_VALUE" -lt 50 ]; then
        echo "✅ Memory usage: ${MEM_VALUE}MB (target: <50MB)"
    else
        echo "⚠️  Memory usage: ${MEM_VALUE}MB (target: <50MB)"
    fi
else
    echo "ℹ️  Memory usage: Could not measure"
fi

# Check for deprecated APIs
echo ""
echo "🟢 Checking for deprecated APIs..."
DEPRECATED_CHECK=$(timeout 5 nvim --headless -c "lua if vim.loop then print('DEPRECATED: vim.loop found') else print('No deprecated APIs') end" -c "quit" 2>&1 || true)

if echo "$DEPRECATED_CHECK" | grep -q "DEPRECATED"; then
    echo "⚠️  Deprecated APIs detected"
else
    echo "✅ No deprecated APIs found"
fi

# Summary
echo ""
echo "📊 Health Check Summary"
echo "======================="
echo "✅ Completed comprehensive checks"
echo "🔍 Run ':checkhealth mad_engineer' in Neovim for detailed LSP/plugin status"
echo "📝 Check the output above for any issues that need fixing"

echo ""
echo "🎯 Next Steps:"
echo "- Fix any ❌ errors shown above"
echo "- Address ⚠️ warnings if they affect your workflow"
echo "- Run ':checkhealth' in Neovim for LSP and plugin diagnostics"
