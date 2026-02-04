import Foundation
import SwiftUI

enum VoiceTypeState: Equatable {
    case idle
    case recording
    case transcribing
    case success
    case error

    var displayText: String {
        switch self {
        case .idle: return ""
        case .recording: return "Recording"
        case .transcribing: return "Transcribing"
        case .success: return "Done"
        case .error: return "Error"
        }
    }

    var iconName: String {
        switch self {
        case .idle: return ""
        case .recording: return "mic.fill"
        case .transcribing: return "waveform"
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .idle: return .clear
        case .recording: return .red
        case .transcribing: return .orange
        case .success: return .green
        case .error: return .red
        }
    }

    var autoHideDelay: Double? {
        switch self {
        case .success: return 1.5
        case .error: return 2.5
        default: return nil
        }
    }
}

@MainActor
class IndicatorStateManager: ObservableObject {
    static let shared = IndicatorStateManager()

    @Published var currentState: VoiceTypeState = .idle
    @Published var isVisible: Bool = false

    private var hideTimer: Timer?

    private init() {}

    func setState(_ state: VoiceTypeState) {
        hideTimer?.invalidate()
        hideTimer = nil

        currentState = state

        if state != .idle {
            isVisible = true
        }

        if let delay = state.autoHideDelay {
            hideTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    self?.hide()
                }
            }
        }
    }

    func hide() {
        hideTimer?.invalidate()
        hideTimer = nil
        isVisible = false
        currentState = .idle
    }
}
