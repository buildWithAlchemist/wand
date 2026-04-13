#!/bin/bash

# Dependency installer and checker for Linux (Ubuntu, Arch, Fedora) and macOS

set -e

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt >/dev/null 2>&1; then
            echo "ubuntu"
        elif command -v pacman >/dev/null 2>&1; then
            echo "arch"
        elif command -v dnf >/dev/null 2>&1; then
            echo "fedora"
        else
            echo "unknown-linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Function to check and install dependency
check_and_install() {
    local cmd=$1
    local package=$2
    local os=$3

    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✓ $cmd found"
    else
        echo "✗ $cmd not found, installing $package..."
        case $os in
            ubuntu)
                sudo apt update && sudo apt install -y "$package"
                ;;
            arch)
                sudo pacman -S --noconfirm "$package"
                ;;
            fedora)
                sudo dnf install -y "$package"
                ;;
            macos)
                if ! command -v brew >/dev/null 2>&1; then
                    echo "Installing Homebrew..."
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                fi
                brew install "$package"
                ;;
            *)
                echo "Unsupported OS for automatic installation of $package"
                exit 1
                ;;
        esac
        echo "✓ $cmd installed"
    fi
}

# Detect OS
OS=$(detect_os)
echo "Detected OS: $OS"

# Dependencies mapping
declare -A deps=(
    ["gcc"]="build-essential"
    ["make"]="build-essential"
    ["python3"]="python3"
    ["cargo"]="rust"
    ["ripgrep"]="ripgrep"
    ["fd"]="fd"
    ["lazygit"]="lazygit"
    ["fzf"]="fzf"
)

# Special cases
case $OS in
    ubuntu)
        deps["fd"]="fd-find"
        ;;
    macos)
        deps["fd"]="fd"
        ;;
esac

# Special handling for Node.js
if command -v node >/dev/null 2>&1; then
    echo "✓ node found"
else
    echo "✗ node not found"
    echo "Choose a Node.js version manager:"
    echo "1) nvm (Node Version Manager)"
    echo "2) fnm (Fast Node Manager)"
    read -p "Enter choice (1 or 2): " choice
    case $choice in
        1)
            echo "Installing nvm..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
            echo "Please restart your shell or run 'source ~/.bashrc' (or ~/.zshrc) to use nvm"
            echo "Then run 'nvm install node' to install Node.js"
            ;;
        2)
            echo "Installing fnm..."
            curl -fsSL https://fnm.vercel.app/install | bash
            echo "Please restart your shell or run 'source ~/.bashrc' (or ~/.zshrc) to use fnm"
            echo "Then run 'fnm install' to install Node.js"
            ;;
        *)
            echo "Invalid choice. Skipping Node.js installation."
            ;;
    esac
fi

# Check and install each dependency
for cmd in gcc make python3 cargo ripgrep fd lazygit fzf; do
    package=${deps[$cmd]}
    check_and_install "$cmd" "$package" "$OS"
done

echo "All dependencies checked/installed successfully!"
