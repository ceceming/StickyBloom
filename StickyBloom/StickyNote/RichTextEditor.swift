import SwiftUI
import AppKit

struct RichTextEditor: NSViewRepresentable {
    @Binding var attributedText: NSAttributedString
    var appState: AppState
    var stickyID: UUID
    var onMentionClicked: ((UUID) -> Void)?

    func makeCoordinator() -> RichTextCoordinator {
        let coordinator = RichTextCoordinator()
        coordinator.appState = appState
        coordinator.stickyID = stickyID
        return coordinator
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.backgroundColor = .clear
        scrollView.drawsBackground = false

        let textView = MentionAwareTextView()
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = true
        textView.allowsUndo = true
        textView.usesRuler = false
        textView.usesFontPanel = true
        textView.importsGraphics = false
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(
            width: scrollView.contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.font = NSFont.systemFont(ofSize: 14)

        // Set coordinator
        textView.delegate = context.coordinator
        textView.textStorage?.delegate = context.coordinator
        context.coordinator.textView = textView

        // Mention click
        textView.onMentionClicked = { uuid in
            onMentionClicked?(uuid)
        }

        // Todo toggle
        textView.onTodoToggled = { charIndex in
            guard let storage = textView.textStorage else { return }
            if let attachment = storage.attribute(.attachment, at: charIndex, effectiveRange: nil) as? NSTextAttachment,
               let cell = attachment.attachmentCell as? TodoCheckboxCell {
                cell.isChecked.toggle()
                // Trigger redisplay
                storage.edited(.editedAttributes, range: NSRange(location: charIndex, length: 1), changeInLength: 0)
            }
        }

        // Wire up text change callback to update the binding
        let binding = _attributedText
        context.coordinator.onTextChange = { attributed in
            DispatchQueue.main.async {
                binding.wrappedValue = attributed
            }
        }

        scrollView.documentView = textView

        // Load initial content
        if !attributedText.string.isEmpty {
            textView.textStorage?.setAttributedString(attributedText)
        }

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        // Never overwrite while the user is actively editing — the coordinator
        // tracks this explicitly so it works correctly on nonactivatingPanel too.
        if !context.coordinator.isUserEditing && textView.attributedString() != attributedText {
            textView.textStorage?.setAttributedString(attributedText)
        }
        context.coordinator.appState = appState
        context.coordinator.stickyID = stickyID
    }
}
