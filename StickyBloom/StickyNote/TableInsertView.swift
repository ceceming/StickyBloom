import SwiftUI
import AppKit

struct TableInsertView: View {
    @Environment(\.dismiss) var dismiss
    @State private var rows = 3
    @State private var columns = 3
    var onInsert: (Int, Int) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Insert Table")
                .font(.headline)

            HStack(spacing: 20) {
                VStack {
                    Text("Rows")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Stepper("\(rows)", value: $rows, in: 1...20)
                }
                VStack {
                    Text("Columns")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Stepper("\(columns)", value: $columns, in: 1...10)
                }
            }

            // Preview grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: min(columns, 8)), spacing: 2) {
                ForEach(0..<min(rows * columns, 64), id: \.self) { _ in
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 12)
                        .border(Color.secondary.opacity(0.4), width: 0.5)
                }
            }
            .frame(maxHeight: 80)
            .clipped()

            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Insert \(rows)×\(columns)") {
                    onInsert(rows, columns)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

// MARK: - NSTextView Table Insertion Helper

extension NSTextView {
    func insertTable(rows: Int, columns: Int) {
        guard let storage = textStorage else { return }

        let table = NSTextTable()
        table.numberOfColumns = columns
        table.setContentWidth(1.0, type: .percentageValueType)

        let cellContent = NSMutableAttributedString()
        let cellFont = NSFont.systemFont(ofSize: 13)

        for row in 0..<rows {
            for col in 0..<columns {
                let block = NSTextTableBlock(table: table, startingRow: row, rowSpan: 1, startingColumn: col, columnSpan: 1)
                block.setContentWidth(1.0 / CGFloat(columns), type: .percentageValueType)
                block.setBorderColor(.separatorColor)
                block.setWidth(0.5, type: .absoluteValueType, for: .border)

                let para = NSMutableParagraphStyle()
                para.textBlocks = [block]

                let cellString = NSMutableAttributedString(
                    string: col == columns - 1 ? "\t\n" : "\t",
                    attributes: [
                        .paragraphStyle: para,
                        .font: cellFont
                    ]
                )
                cellContent.append(cellString)
            }
        }

        let insertRange = selectedRange()
        storage.replaceCharacters(in: insertRange, with: cellContent)
        setSelectedRange(NSRange(location: insertRange.location + 1, length: 0))
    }
}
