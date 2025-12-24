# macOS Voice Type

**Free, offline voice-to-text for macOS using Whisper AI.**

Press a hotkey anywhere, speak, and your words are typed automatically. No subscription, no cloud, no API keys - runs 100% locally on your Mac.

## Features

- **Hotkey voice typing** - Press a shortcut anywhere to dictate text
- **Offline & private** - Uses Whisper AI locally, no data leaves your Mac
- **Auto-stops on silence** - Just pause speaking and it stops recording
- **Fast** - Uses the tiny.en model for quick transcription
- **Free** - No subscriptions or API costs
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
4. Create the Automator Quick Action

## Manual Setup After Install

### 1. Set Your Keyboard Shortcut

1. Open **System Settings**
2. Go to **Keyboard** > **Keyboard Shortcuts** > **Services**
3. Scroll to **General** and find **"Voice Type"**
4. Click "none" next to it and press your desired shortcut
   - Recommended: `Control + Option + Command + P`

### 2. Grant Permissions

When you first use voice typing, macOS will ask for:

- **Microphone access** - Required to record your voice
- **Accessibility access** - Required to type the transcribed text

Go to **System Settings** > **Privacy & Security** to manage these.

### 3. Add ~/bin to PATH (if needed)

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
5. Hear the "glass" sound - text is typed

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
[AppleScript] --> Types text via System Events
```

**Models used:**
- `ggml-tiny.en.bin` (75MB) - Fast, used for hotkey typing
- `ggml-base.en.bin` (142MB) - More accurate, used for Claude commands

## Troubleshooting

### "No audio captured"
- Check microphone permissions in System Settings > Privacy & Security
- Make sure your microphone is working

### Shortcut doesn't work
- Verify the shortcut is set in System Settings > Keyboard > Keyboard Shortcuts > Services
- Make sure "Voice Type" is checked/enabled
- Try a different shortcut (some may be reserved)

### "Basso" error sound plays
- Recording failed or transcription was empty
- Speak more clearly and closer to the microphone
- Check that whisper-cpp is installed: `which whisper-cli`

### Text isn't typed
- Grant Accessibility access to Automator and/or Terminal
- System Settings > Privacy & Security > Accessibility

### voice-claude not found
- Add `~/bin` to your PATH (see setup above)
- Or use full path: `~/bin/voice-claude`

## Uninstall

```bash
# Remove scripts
rm ~/bin/voice-type ~/bin/voice-claude ~/bin/voice-claude-chat

# Remove Automator workflow
rm -rf ~/Library/Services/Voice\ Type.workflow

# Remove models (optional, ~250MB)
rm -rf ~/.local/share/whisper-cpp

# Remove dependencies (optional)
brew uninstall whisper-cpp sox
```

## Credits

- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) - High-performance Whisper inference
- [OpenAI Whisper](https://github.com/openai/whisper) - Original speech recognition model
- [SoX](https://sox.sourceforge.net/) - Audio recording and processing

## License

MIT License - see [LICENSE](LICENSE)
