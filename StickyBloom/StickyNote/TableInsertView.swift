import SwiftUI
import AppKit

// MARK: - Table Insert Window Controller

final class TableInsertWindowController: NSWindowController {
    private let onDismiss: () -> Void

    init(textView: NSTextView, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 260),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Insert Table"
        window.center()

        super.init(window: window)

        let view = TableInsertView { [weak textView] rows, cols in
            textView?.insertTable(rows: rows, columns: cols)
            window.close()
            onDismiss()
        } onCancel: {
            window.close()
            onDismiss()
        }
        window.contentView = NSHostingView(rootView: view)
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Table Insert View

struct TableInsertView: View {
    @State private var rows = 3
    @State private var columns = 3
    var onInsert: (Int, Int) -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Insert Table")
                .font(.headline)

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rows").font(.caption).foregroundStyle(.secondary)
                    Stepper("\(rows)", value: $rows, in: 1...20)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Columns").font(.caption).foregroundStyle(.secondary)
                    Stepper("\(columns)", value: $columns, in: 1...10)
                }
            }

            // Preview grid
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: min(columns, 8)),
                spacing: 2
            ) {
                ForEach(0..<min(rows * columns, 64), id: \.self) { _ in
                    Rectangle()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 14)
                        .border(Color.secondary.opacity(0.4), width: 0.5)
                }
            }
            .frame(maxHeight: 80)
            .clipped()

            HStack {
                Button("Cancel") { onCancel() }
                    .keyboardShortcut(.escape, modifiers: [])
                Spacer()
                Button("Insert \(rows)×\(columns)") { onInsert(rows, columns) }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: [])
            }
        }
        .padding(20)
        .frame(width: 320)
    }
}

// MARK: - NSTextView Table Insertion

extension NSTextView {
    func insertTable(rows: Int, columns: Int) {
        guard let storage = textStorage else { return }

        let table = NSTextTable()
        table.numberOfColumns = columns
        table.setContentWidth(1.0, type: .percentageValueType)
        table.collapsesBorders = true

        let cellFont = font ?? NSFont.systemFont(ofSize: 13)
        let result = NSMutableAttributedString()

        for row in 0..<rows {
            for col in 0..<columns {
                let block = NSTextTableBlock(
                    table: table,
                    startingRow: row, rowSpan: 1,
                    startingColumn: col, columnSpan: 1
                )
                block.setContentWidth(1.0 / CGFloat(columns), type: .percentageValueType)
                block.setBorderColor(.separatorColor)
                block.setWidth(1, type: .absoluteValueType, for: .border)
                block.setWidth(4, type: .absoluteValueType, for: .padding)

                let para = NSMutableParagraphStyle()
                para.textBlocks = [block]

                // Every cell must end with \n to form a proper paragraph
                let cell = NSMutableAttributedString(
                    string: " \n",
                    attributes: [.paragraphStyle: para, .font: cellFont]
                )
                result.append(cell)
            }
        }

        let insertRange = selectedRange()
        storage.replaceCharacters(in: insertRange, with: result)
        // Place cursor inside the first cell (before the \n)
        setSelectedRange(NSRange(location: insertRange.location + 1, length: 0))
        scrollRangeToVisible(selectedRange())
    }
}
