import SwiftUI

struct FloatingIndicatorView: View {
    @ObservedObject var stateManager = IndicatorStateManager.shared

    @State private var isPulsing = false
    @State private var rotation: Double = 0

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                if stateManager.currentState == .recording {
                    Circle()
                        .fill(Color.red.opacity(isPulsing ? 0.3 : 0.6))
                        .frame(width: 24, height: 24)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isPulsing)
                }

                if stateManager.currentState == .transcribing {
                    Image(systemName: stateManager.currentState.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(stateManager.currentState.iconColor)
                        .rotationEffect(.degrees(rotation))
                        .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: rotation)
                } else {
                    Image(systemName: stateManager.currentState.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(stateManager.currentState.iconColor)
                }
            }
            .frame(width: 24, height: 24)

            Text(stateManager.currentState.displayText)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            Capsule()
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .onAppear {
            isPulsing = true
            rotation = 360
        }
        .onChange(of: stateManager.currentState) { newState in
            if newState == .recording {
                isPulsing = true
            }
            if newState == .transcribing {
                rotation = 0
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
        }
    }
}
