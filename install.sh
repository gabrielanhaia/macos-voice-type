#!/bin/bash
#
# macos-voice-type installer
# Installs voice-to-text for macOS using Whisper AI
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "================================================"
echo "   macOS Voice Type Installer"
echo "   Offline voice-to-text using Whisper AI"
echo "================================================"
echo -e "${NC}"

# Get the directory where install.sh is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}Error: This script only works on macOS${NC}"
    exit 1
fi

# Check macOS version (requires Monterey 12+ for Shortcuts)
macos_version=$(sw_vers -productVersion | cut -d. -f1)
if [[ "$macos_version" -lt 12 ]]; then
    echo -e "${RED}Error: macOS 12 (Monterey) or later is required${NC}"
    exit 1
fi

# Check for Apple Silicon vs Intel
if [[ "$(uname -m)" == "arm64" ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
else
    HOMEBREW_PREFIX="/usr/local"
fi

echo -e "${BLUE}Step 1: Checking Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew not found. Installing...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH for this session
    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
fi
echo -e "${GREEN}Homebrew OK${NC}"

echo ""
echo -e "${BLUE}Step 2: Installing dependencies (whisper-cpp, sox)...${NC}"
brew install whisper-cpp sox
echo -e "${GREEN}Dependencies installed${NC}"

echo ""
echo -e "${BLUE}Step 3: Downloading Whisper models...${NC}"
MODEL_DIR="$HOME/.local/share/whisper-cpp"
mkdir -p "$MODEL_DIR"

# Download tiny.en model (fast, for hotkey typing)
if [ ! -f "$MODEL_DIR/ggml-tiny.en.bin" ]; then
    echo "Downloading tiny.en model (75MB)..."
    curl -L "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin" \
        -o "$MODEL_DIR/ggml-tiny.en.bin"
else
    echo "tiny.en model already exists"
fi

# Download base.en model (better accuracy, for terminal commands)
if [ ! -f "$MODEL_DIR/ggml-base.en.bin" ]; then
    echo "Downloading base.en model (142MB)..."
    curl -L "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin" \
        -o "$MODEL_DIR/ggml-base.en.bin"
else
    echo "base.en model already exists"
fi
echo -e "${GREEN}Models downloaded${NC}"

echo ""
echo -e "${BLUE}Step 4: Installing scripts to ~/bin/...${NC}"
mkdir -p "$HOME/bin"

# Copy scripts
cp "$SCRIPT_DIR/scripts/voice-type" "$HOME/bin/"
cp "$SCRIPT_DIR/scripts/voice-shortcut" "$HOME/bin/"
cp "$SCRIPT_DIR/scripts/voice-claude" "$HOME/bin/"
cp "$SCRIPT_DIR/scripts/voice-claude-chat" "$HOME/bin/"

# Make executable
chmod +x "$HOME/bin/voice-type"
chmod +x "$HOME/bin/voice-shortcut"
chmod +x "$HOME/bin/voice-claude"
chmod +x "$HOME/bin/voice-claude-chat"

echo -e "${GREEN}Scripts installed${NC}"

echo ""
echo -e "${BLUE}Step 4b: Building voicetype-notify CLI tool...${NC}"
swiftc -O -o "$HOME/bin/voicetype-notify" "$SCRIPT_DIR/voicetype-notify/main.swift"
chmod +x "$HOME/bin/voicetype-notify"
echo -e "${GREEN}CLI tool installed${NC}"

# Check if ~/bin is in PATH
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo ""
    echo -e "${YELLOW}Note: ~/bin is not in your PATH${NC}"
    echo "Add this to your ~/.zshrc or ~/.bashrc:"
    echo -e "${CYAN}  export PATH=\"\$HOME/bin:\$PATH\"${NC}"
fi

echo ""
echo -e "${BLUE}Step 5: Creating VoiceType.app...${NC}"

# Create AppleScript-based app for Accessibility permissions
cat > /tmp/voicetype.applescript << 'APPLESCRIPT'
-- VoiceType: Record, transcribe, and type
-- This app has Accessibility permission to type text

set homeFolder to (do shell script "echo $HOME")
set shortcutScript to homeFolder & "/bin/voice-shortcut"

try
    do shell script shortcutScript
on error errMsg
    -- Error handled by voice-shortcut (plays error sound)
end try
APPLESCRIPT

osacompile -o /Applications/VoiceType.app /tmp/voicetype.applescript

# Make it a background app (no dock icon)
/usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" /Applications/VoiceType.app/Contents/Info.plist 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Set :LSUIElement true" /Applications/VoiceType.app/Contents/Info.plist

rm /tmp/voicetype.applescript

echo -e "${GREEN}VoiceType.app created${NC}"

echo ""
echo -e "${BLUE}Step 6: Building VoiceTypeIndicator.app...${NC}"

# Build the SwiftUI indicator app using Swift Package Manager
INDICATOR_PROJECT="$SCRIPT_DIR/VoiceTypeIndicator"
if [ -d "$INDICATOR_PROJECT" ]; then
    cd "$INDICATOR_PROJECT"

    # Build with Swift Package Manager
    if swift build -c release 2>/dev/null; then
        # Create app bundle structure
        APP_BUNDLE="/Applications/VoiceTypeIndicator.app"
        rm -rf "$APP_BUNDLE"
        mkdir -p "$APP_BUNDLE/Contents/MacOS"

        # Copy executable
        cp ".build/release/VoiceTypeIndicator" "$APP_BUNDLE/Contents/MacOS/"

        # Copy Info.plist
        cp "VoiceTypeIndicator/Info.plist" "$APP_BUNDLE/Contents/"

        # Update Info.plist with correct executable name
        /usr/libexec/PlistBuddy -c "Set :CFBundleExecutable VoiceTypeIndicator" "$APP_BUNDLE/Contents/Info.plist"
        /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.voicetype.indicator" "$APP_BUNDLE/Contents/Info.plist"
        /usr/libexec/PlistBuddy -c "Set :CFBundleName VoiceTypeIndicator" "$APP_BUNDLE/Contents/Info.plist"

        echo -e "${GREEN}VoiceTypeIndicator.app installed${NC}"

        # Start the indicator
        echo -e "${YELLOW}Starting VoiceTypeIndicator...${NC}"
        open "$APP_BUNDLE"

        # Clean up build artifacts
        rm -rf ".build"
    else
        echo -e "${YELLOW}Warning: Could not build VoiceTypeIndicator.app${NC}"
        echo "Make sure Xcode Command Line Tools are installed: xcode-select --install"
    fi

    cd "$SCRIPT_DIR"
else
    echo -e "${YELLOW}Warning: VoiceTypeIndicator project not found${NC}"
fi

echo ""
echo -e "${CYAN}================================================${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT: Complete these setup steps:${NC}"
echo ""
echo "1. ${BLUE}Grant Accessibility permission:${NC}"
echo "   - Open System Settings > Privacy & Security > Accessibility"
echo "   - Click + and add /Applications/VoiceType.app"
echo "   - Make sure the toggle is ON"
echo ""
echo "2. ${BLUE}Create keyboard shortcut in Shortcuts app:${NC}"
echo "   - Open the Shortcuts app (Cmd+Space, type 'Shortcuts')"
echo "   - Click + to create a new shortcut"
echo "   - Search for 'Run Shell Script' and add it"
echo "   - Enter: $HOME/bin/voice-shortcut"
echo "   - Click the shortcut name > Add Keyboard Shortcut"
echo "   - Press your desired keys (e.g., Ctrl+Option+V)"
echo ""
echo "3. ${BLUE}Grant Microphone permission:${NC}"
echo "   - When you first use voice typing, allow microphone access"
echo ""
echo "4. ${BLUE}Add ~/bin to PATH${NC} (if not already):"
echo "   echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> ~/.zshrc"
echo "   source ~/.zshrc"
echo ""
echo -e "${GREEN}Usage:${NC}"
echo "  - Press your hotkey anywhere to voice type"
echo "  - Run 'voice-claude' in terminal for voice -> Claude"
echo "  - Run 'voice-claude-chat' for interactive voice chat"
echo ""
echo -e "${GREEN}Visual Indicator:${NC}"
echo "  VoiceTypeIndicator.app shows recording/transcribing status"
echo "  It runs in the background (no Dock icon)"
echo "  To start on login: System Settings > General > Login Items > add VoiceTypeIndicator"
echo ""
echo -e "${CYAN}Tip: After setting up, restart any app where you want to use voice typing.${NC}"
echo ""
