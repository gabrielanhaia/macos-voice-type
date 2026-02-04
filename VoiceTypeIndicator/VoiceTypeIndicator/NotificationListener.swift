import Foundation

// Darwin notification C functions
@_silgen_name("notify_register_dispatch")
func notify_register_dispatch(
    _ name: UnsafePointer<CChar>,
    _ out_token: UnsafeMutablePointer<Int32>,
    _ queue: DispatchQueue,
    _ handler: @escaping @convention(block) (Int32) -> Void
) -> UInt32

@_silgen_name("notify_cancel")
func notify_cancel(_ token: Int32) -> UInt32

class NotificationListener {
    static let shared = NotificationListener()

    private var recordingToken: Int32 = 0
    private var transcribingToken: Int32 = 0
    private var successToken: Int32 = 0
    private var errorToken: Int32 = 0
    private var hideToken: Int32 = 0

    private init() {}

    func startListening() {
        let queue = DispatchQueue.main

        _ = notify_register_dispatch("com.voicetype.recording", &recordingToken, queue) { _ in
            Task { @MainActor in
                IndicatorStateManager.shared.setState(.recording)
            }
        }

        _ = notify_register_dispatch("com.voicetype.transcribing", &transcribingToken, queue) { _ in
            Task { @MainActor in
                IndicatorStateManager.shared.setState(.transcribing)
            }
        }

        _ = notify_register_dispatch("com.voicetype.success", &successToken, queue) { _ in
            Task { @MainActor in
                IndicatorStateManager.shared.setState(.success)
            }
        }

        _ = notify_register_dispatch("com.voicetype.error", &errorToken, queue) { _ in
            Task { @MainActor in
                IndicatorStateManager.shared.setState(.error)
            }
        }

        _ = notify_register_dispatch("com.voicetype.hide", &hideToken, queue) { _ in
            Task { @MainActor in
                IndicatorStateManager.shared.hide()
            }
        }
    }

    func stopListening() {
        _ = notify_cancel(recordingToken)
        _ = notify_cancel(transcribingToken)
        _ = notify_cancel(successToken)
        _ = notify_cancel(errorToken)
        _ = notify_cancel(hideToken)
    }
}
