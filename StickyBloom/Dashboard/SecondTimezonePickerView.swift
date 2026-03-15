import SwiftUI

struct SecondTimezonePickerView: View {
    @Binding var selectedIdentifier: String?
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
                Text("Select Timezone")
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

            if selectedIdentifier != nil {
                Button("Remove Second Timezone") {
                    selectedIdentifier = nil
                    dismiss()
                }
                .foregroundStyle(.red)
                .padding()
            }
        }
        .frame(width: 360, height: 460)
    }

    @ViewBuilder
    private var zoneRows: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
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
