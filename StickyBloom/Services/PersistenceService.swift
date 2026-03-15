import Foundation

final class PersistenceService {
    static let shared = PersistenceService()

    private let baseURL: URL

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        baseURL = appSupport.appendingPathComponent("StickyBloom", isDirectory: true)
        try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }

    private var stickiesURL: URL { baseURL.appendingPathComponent("stickies.json") }
    private var dashboardURL: URL { baseURL.appendingPathComponent("dashboard.json") }
    private var projectsURL: URL { baseURL.appendingPathComponent("projects.json") }

    func loadStickies() -> [StickyNoteModel] {
        guard let data = try? Data(contentsOf: stickiesURL) else { return [] }
        return (try? JSONDecoder().decode([StickyNoteModel].self, from: data)) ?? []
    }

    func saveStickies(_ stickies: [StickyNoteModel]) {
        guard let data = try? JSONEncoder().encode(stickies) else { return }
        try? data.write(to: stickiesURL, options: .atomic)
    }

    func loadDashboardSettings() -> DashboardSettingsModel {
        guard let data = try? Data(contentsOf: dashboardURL) else { return DashboardSettingsModel() }
        return (try? JSONDecoder().decode(DashboardSettingsModel.self, from: data)) ?? DashboardSettingsModel()
    }

    func saveDashboardSettings(_ settings: DashboardSettingsModel) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        try? data.write(to: dashboardURL, options: .atomic)
    }

    func loadProjects() -> [ProjectModel] {
        guard let data = try? Data(contentsOf: projectsURL) else { return [] }
        return (try? JSONDecoder().decode([ProjectModel].self, from: data)) ?? []
    }

    func saveProjects(_ projects: [ProjectModel]) {
        guard let data = try? JSONEncoder().encode(projects) else { return }
        try? data.write(to: projectsURL, options: .atomic)
    }
}
