import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var stickies: [StickyNoteModel] = []
    @Published var dashboardSettings: DashboardSettingsModel = DashboardSettingsModel()

    private let persistence = PersistenceService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        load()
        setupAutoSave()
    }

    private func load() {
        stickies = persistence.loadStickies()
        dashboardSettings = persistence.loadDashboardSettings()
    }

    private func setupAutoSave() {
        $stickies
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] stickies in
                self?.persistence.saveStickies(stickies)
            }
            .store(in: &cancellables)

        $dashboardSettings
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] settings in
                self?.persistence.saveDashboardSettings(settings)
            }
            .store(in: &cancellables)
    }

    func saveAll() {
        persistence.saveStickies(stickies)
        persistence.saveDashboardSettings(dashboardSettings)
    }

    func addSticky(_ sticky: StickyNoteModel) {
        stickies.append(sticky)
    }

    func updateSticky(_ sticky: StickyNoteModel) {
        if let idx = stickies.firstIndex(where: { $0.id == sticky.id }) {
            stickies[idx] = sticky
        }
    }

    func removeSticky(id: UUID) {
        stickies.removeAll { $0.id == id }
    }

    func sticky(for id: UUID) -> StickyNoteModel? {
        stickies.first { $0.id == id }
    }
}
