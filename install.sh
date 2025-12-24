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
cp "$SCRIPT_DIR/scripts/voice-claude" "$HOME/bin/"
cp "$SCRIPT_DIR/scripts/voice-claude-chat" "$HOME/bin/"

# Make executable
chmod +x "$HOME/bin/voice-type"
chmod +x "$HOME/bin/voice-claude"
chmod +x "$HOME/bin/voice-claude-chat"

echo -e "${GREEN}Scripts installed${NC}"

# Check if ~/bin is in PATH
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo ""
    echo -e "${YELLOW}Note: ~/bin is not in your PATH${NC}"
    echo "Add this to your ~/.zshrc or ~/.bashrc:"
    echo -e "${CYAN}  export PATH=\"\$HOME/bin:\$PATH\"${NC}"
fi

echo ""
echo -e "${BLUE}Step 5: Creating Automator Quick Action...${NC}"

WORKFLOW_DIR="$HOME/Library/Services/Voice Type.workflow/Contents"
mkdir -p "$WORKFLOW_DIR"

# Create the workflow plist
cat > "$WORKFLOW_DIR/document.wflow" << 'WFLOW'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AMApplicationBuild</key>
	<string>523</string>
	<key>AMApplicationVersion</key>
	<string>2.10</string>
	<key>AMDocumentVersion</key>
	<string>2</string>
	<key>actions</key>
	<array>
		<dict>
			<key>action</key>
			<dict>
				<key>AMAccepts</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Optional</key>
					<true/>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.string</string>
					</array>
				</dict>
				<key>AMActionVersion</key>
				<string>2.0.3</string>
				<key>AMApplication</key>
				<array>
					<string>Automator</string>
				</array>
				<key>AMCategory</key>
				<string>AMCategoryUtilities</string>
				<key>AMIconName</key>
				<string>Run Shell Script</string>
				<key>AMName</key>
				<string>Run Shell Script</string>
				<key>AMProvides</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.string</string>
					</array>
				</dict>
				<key>ActionBundlePath</key>
				<string>/System/Library/Automator/Run Shell Script.action</string>
				<key>ActionName</key>
				<string>Run Shell Script</string>
				<key>ActionParameters</key>
				<dict>
					<key>COMMAND_STRING</key>
					<string>$HOME/bin/voice-type</string>
					<key>CheckedForUserDefaultShell</key>
					<true/>
					<key>inputMethod</key>
					<integer>1</integer>
					<key>shell</key>
					<string>/bin/zsh</string>
					<key>source</key>
					<string></string>
				</dict>
				<key>BundleIdentifier</key>
				<string>com.apple.RunShellScript</string>
				<key>CFBundleVersion</key>
				<string>2.0.3</string>
				<key>CanShowSelectedItemsWhenRun</key>
				<false/>
				<key>CanShowWhenRun</key>
				<true/>
				<key>Category</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>Class Name</key>
				<string>RunShellScriptAction</string>
				<key>InputUUID</key>
				<string>E9C79C86-B9D3-4E4A-8E0D-4C0E6B8F5B1C</string>
				<key>Keywords</key>
				<array>
					<string>Shell</string>
					<string>Script</string>
					<string>Command</string>
					<string>Run</string>
					<string>Unix</string>
				</array>
				<key>OutputUUID</key>
				<string>A1B2C3D4-E5F6-7890-ABCD-EF1234567890</string>
				<key>UUID</key>
				<string>F1E2D3C4-B5A6-9870-1234-567890ABCDEF</string>
				<key>UnlocalizedApplications</key>
				<array>
					<string>Automator</string>
				</array>
				<key>arguments</key>
				<dict>
					<key>0</key>
					<dict>
						<key>default value</key>
						<integer>0</integer>
						<key>name</key>
						<string>inputMethod</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>0</string>
					</dict>
					<key>1</key>
					<dict>
						<key>default value</key>
						<string></string>
						<key>name</key>
						<string>source</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>1</string>
					</dict>
					<key>2</key>
					<dict>
						<key>default value</key>
						<false/>
						<key>name</key>
						<string>CheckedForUserDefaultShell</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>2</string>
					</dict>
					<key>3</key>
					<dict>
						<key>default value</key>
						<string></string>
						<key>name</key>
						<string>COMMAND_STRING</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>3</string>
					</dict>
					<key>4</key>
					<dict>
						<key>default value</key>
						<string>/bin/zsh</string>
						<key>name</key>
						<string>shell</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>4</string>
					</dict>
				</dict>
			</dict>
		</dict>
	</array>
	<key>connectors</key>
	<dict/>
	<key>workflowMetaData</key>
	<dict>
		<key>workflowTypeIdentifier</key>
		<string>com.apple.Automator.servicesMenu</string>
	</dict>
</dict>
</plist>
WFLOW

# Create Info.plist
cat > "$WORKFLOW_DIR/Info.plist" << 'INFOPLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSServices</key>
	<array>
		<dict>
			<key>NSMenuItem</key>
			<dict>
				<key>default</key>
				<string>Voice Type</string>
			</dict>
			<key>NSMessage</key>
			<string>runWorkflowAsService</string>
		</dict>
	</array>
</dict>
</plist>
INFOPLIST

echo -e "${GREEN}Quick Action created${NC}"

echo ""
echo -e "${CYAN}================================================${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT: Final setup steps:${NC}"
echo ""
echo "1. ${BLUE}Set keyboard shortcut:${NC}"
echo "   - Open System Settings"
echo "   - Go to Keyboard > Keyboard Shortcuts > Services"
echo "   - Find 'Voice Type' under 'General'"
echo "   - Click 'none' and press your shortcut (e.g., Control+Option+Command+P)"
echo ""
echo "2. ${BLUE}Grant permissions when prompted:${NC}"
echo "   - Microphone access (for recording)"
echo "   - Accessibility access (for typing text)"
echo ""
echo "3. ${BLUE}Add ~/bin to PATH${NC} (if not already):"
echo "   echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> ~/.zshrc"
echo "   source ~/.zshrc"
echo ""
echo -e "${GREEN}Usage:${NC}"
echo "  - Press your hotkey anywhere to voice type"
echo "  - Run 'voice-claude' in terminal for voice -> Claude"
echo "  - Run 'voice-claude-chat' for interactive voice chat"
echo ""
