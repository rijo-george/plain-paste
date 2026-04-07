import AppKit

class PasteboardMonitor {
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private var isSelfChange = false

    func start() {
        guard timer == nil else { return }
        lastChangeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    var isRunning: Bool {
        timer != nil
    }

    private func checkPasteboard() {
        let pb = NSPasteboard.general
        let currentCount = pb.changeCount

        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        // Skip if we just wrote to the pasteboard ourselves
        if isSelfChange {
            isSelfChange = false
            return
        }

        // Check if there's rich text that needs stripping
        let hasRichContent = pb.types?.contains(where: {
            $0 == .rtf || $0 == .rtfd || $0 == .html
        }) ?? false

        guard hasRichContent else { return }

        // Get the plain text version
        guard let plainText = pb.string(forType: .string), !plainText.isEmpty else { return }

        // Replace pasteboard with plain text only
        isSelfChange = true
        pb.clearContents()
        pb.setString(plainText, forType: .string)
        lastChangeCount = pb.changeCount
    }
}
