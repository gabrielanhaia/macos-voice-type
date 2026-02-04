import Foundation

// Darwin notification functions are available through this C interop
@_silgen_name("notify_post")
func notify_post(_ name: UnsafePointer<CChar>) -> UInt32

let validStates = ["recording", "transcribing", "success", "error", "hide"]

guard CommandLine.arguments.count >= 2 else {
    fputs("Usage: voicetype-notify <state>\n", stderr)
    fputs("States: \(validStates.joined(separator: ", "))\n", stderr)
    exit(1)
}

let state = CommandLine.arguments[1]

guard validStates.contains(state) else {
    fputs("Error: Invalid state '\(state)'\n", stderr)
    fputs("Valid states: \(validStates.joined(separator: ", "))\n", stderr)
    exit(1)
}

let notificationName = "com.voicetype.\(state)"
_ = notify_post(notificationName)
