import SwiftUI

struct TimezonePickerView: View {
    let title: String
    @Binding var selectedIdentifier: String?
    let noneOptionTitle: String?
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    private var filteredZones: [String] {
        let all = TimeZone.knownTimeZoneIdentifiers.sorted()
        if searchText.isEmpty { return all }
        return all.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Button("Done") { dismiss() }
            }
            .padding()

            TextField("Search...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .padding(.bottom, 8)

            ScrollView {
                zoneRows
            }
        }
        .frame(width: 360, height: 460)
    }

    @ViewBuilder
    private var zoneRows: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            if let noneOptionTitle {
                Button {
                    selectedIdentifier = nil
                    dismiss()
                } label: {
                    HStack {
                        Text(noneOptionTitle)
                            .font(.body)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if selectedIdentifier == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Divider()
            }

            ForEach(AnyRandomAccessCollection<String>(filteredZones), id: \.self) { (identifier: String) in
                Button {
                    selectedIdentifier = identifier
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(TimeZone(identifier: identifier)?.displayName ?? identifier)
                                .font(.body)
                            Text(identifier)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if selectedIdentifier == identifier {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Divider()
            }
        }
    }
}
