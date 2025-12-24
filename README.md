# macOS Voice Type

**Free, offline voice-to-text for macOS using Whisper AI.**

Press a hotkey anywhere, speak, and your words are typed automatically. No subscription, no cloud, no API keys - runs 100% locally on your Mac.

![Demo](demo.gif)

## Features

- **Hotkey voice typing** - Press a shortcut anywhere to dictate text
- **Offline & private** - Uses Whisper AI locally, no data leaves your Mac
- **Auto-stops on silence** - Just pause speaking and it stops recording
- **Fast** - Uses the tiny.en model for quick transcription
- **Free** - No subscriptions or API costs
- **Works everywhere** - Chrome, Safari, Notes, VS Code, and any other app
- **Claude Code integration** - Voice commands for Claude Code CLI (optional)

## Requirements

- macOS 12 (Monterey) or later
- [Homebrew](https://brew.sh) (will be installed automatically if missing)
- ~250MB disk space for Whisper models

## Quick Install

```bash
git clone https://github.com/gabrielanhaia/macos-voice-type.git
cd macos-voice-type
./install.sh
```

The installer will:
1. Install dependencies (whisper-cpp, sox)
2. Download Whisper AI models
3. Install voice scripts to `~/bin/`
4. Create the VoiceType.app

## Manual Setup After Install

### 1. Grant Accessibility Permission

1. Open **System Settings** > **Privacy & Security** > **Accessibility**
2. Click **+** and navigate to `/Applications/VoiceType.app`
3. Make sure the toggle is **ON**

### 2. Create Keyboard Shortcut

1. Open the **Shortcuts** app (Cmd+Space, type "Shortcuts")
2. Click **+** to create a new shortcut
3. Name it "Voice Type"
4. Search for **"Run Shell Script"** and add it
5. Enter: `$HOME/bin/voice-shortcut`
6. Click the shortcut name at the top
7. Click **"Add Keyboard Shortcut"**
8. Press your desired keys (e.g., `Ctrl + Option + V`)

### 3. Grant Microphone Permission

When you first use voice typing, macOS will ask for microphone access. Allow it.

### 4. Add ~/bin to PATH (if needed)

If `voice-claude` commands don't work, add this to your `~/.zshrc`:

```bash
export PATH="$HOME/bin:$PATH"
```

Then run `source ~/.zshrc`.

## Usage

### Voice Typing (Hotkey)

1. Focus any text field (browser, editor, chat, etc.)
2. Press your keyboard shortcut
3. Hear the "pop" sound - start speaking
4. Pause for 1.5 seconds
5. Hear the "glass" sound - text is pasted

### Voice to Claude (Terminal)

Send a single voice command to Claude Code:

```bash
voice-claude
```

### Interactive Voice Chat (Terminal)

Have a back-and-forth voice conversation with Claude:

```bash
voice-claude-chat
```

Press Enter to speak, Ctrl+C to exit.

## How It Works

```
Your Voice
    |
    v
[sox/rec] --> Records audio with silence detection
    |
    v
[whisper-cpp] --> Transcribes using Whisper AI (tiny.en model)
    |
    v
[Clipboard + Paste] --> Types text via Cmd+V
```

**Models used:**
- `ggml-tiny.en.bin` (75MB) - Fast, used for hotkey typing
- `ggml-base.en.bin` (142MB) - More accurate, used for Claude commands

## Troubleshooting

### "No audio captured"
- Check microphone permissions in System Settings > Privacy & Security > Microphone
- Make sure your microphone is working

### Shortcut doesn't work
- Make sure the shortcut is set in the Shortcuts app
- Try a different key combination (some may conflict with other apps)
- **Restart the app** where you want to use voice typing

### Shortcut works in some apps but not others
- Some apps (like Chrome) need to be restarted after setting up
- Make sure VoiceType.app has Accessibility permission

### "Basso" error sound plays
- Recording failed or transcription was empty
- Speak more clearly and closer to the microphone
- Check that whisper-cpp is installed: `which whisper-cli`

### Text isn't typed
- Grant Accessibility access to VoiceType.app
- System Settings > Privacy & Security > Accessibility
- Make sure the toggle is ON

### voice-claude not found
- Add `~/bin` to your PATH (see setup above)
- Or use full path: `~/bin/voice-claude`

## Uninstall

```bash
# Remove scripts
rm ~/bin/voice-type ~/bin/voice-shortcut ~/bin/voice-claude ~/bin/voice-claude-chat

# Remove VoiceType app
rm -rf /Applications/VoiceType.app

# Remove models (optional, ~250MB)
rm -rf ~/.local/share/whisper-cpp

# Remove dependencies (optional)
brew uninstall whisper-cpp sox

# Remove the shortcut manually from Shortcuts app
```

## Credits

- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) - High-performance Whisper inference
- [OpenAI Whisper](https://github.com/openai/whisper) - Original speech recognition model
- [SoX](https://sox.sourceforge.net/) - Audio recording and processing

## License

MIT License - see [LICENSE](LICENSE)
