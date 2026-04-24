import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var stickies: [StickyNoteModel] = []
    @Published var dashboardSettings: DashboardSettingsModel = DashboardSettingsModel()
    @Published var projects: [ProjectModel] = []

    private let persistence = PersistenceService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        load()
        TextFileSyncService.shared.sync(stickies: stickies)
        setupAutoSave()
    }

    private func load() {
        stickies = persistence.loadStickies()
        dashboardSettings = persistence.loadDashboardSettings()
        projects = persistence.loadProjects()
    }

    private func setupAutoSave() {
        // Synchronous saves on every change — no debounce window means a
        // crash or force-quit cannot lose in-flight edits.
        $stickies
            .sink { [weak self] stickies in
                self?.persistence.saveStickies(stickies)
                TextFileSyncService.shared.sync(stickies: stickies)
            }
            .store(in: &cancellables)

        $dashboardSettings
            .sink { [weak self] settings in
                self?.persistence.saveDashboardSettings(settings)
            }
            .store(in: &cancellables)

        $projects
            .sink { [weak self] projects in
                self?.persistence.saveProjects(projects)
            }
            .store(in: &cancellables)
    }

    func saveAll() {
        persistence.saveStickies(stickies)
        persistence.saveDashboardSettings(dashboardSettings)
        persistence.saveProjects(projects)
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

    // MARK: - Projects

    func addProject(_ project: ProjectModel) {
        projects.append(project)
    }

    func updateProject(_ project: ProjectModel) {
        if let idx = projects.firstIndex(where: { $0.id == project.id }) {
            projects[idx] = project
        }
    }

    func removeProject(id: UUID) {
        for i in stickies.indices where stickies[i].projectID == id {
            stickies[i].projectID = nil
        }
        projects.removeAll { $0.id == id }
    }

    func assignSticky(id: UUID, toProject projectID: UUID?) {
        if let idx = stickies.firstIndex(where: { $0.id == id }) {
            stickies[idx].projectID = projectID
        }
    }
}
