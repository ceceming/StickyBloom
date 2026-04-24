import Foundation

final class PersistenceService {
    static let shared = PersistenceService()

    private let baseURL: URL

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        baseURL = appSupport.appendingPathComponent("StickyBloom", isDirectory: true)
        try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
        migrateFromSandboxContainerIfNeeded()
    }

    private func migrateFromSandboxContainerIfNeeded() {
        let fm = FileManager.default
        guard !fm.fileExists(atPath: stickiesURL.path) else { return }

        let home = fm.homeDirectoryForCurrentUser
        let containerBase = home
            .appendingPathComponent("Library/Containers/com.ecemozturk.StickyBloom/Data/Library/Application Support/StickyBloom", isDirectory: true)

        for filename in ["stickies.json", "dashboard.json", "projects.json"] {
            let source = containerBase.appendingPathComponent(filename)
            let destination = baseURL.appendingPathComponent(filename)
            guard fm.fileExists(atPath: source.path),
                  !fm.fileExists(atPath: destination.path) else { continue }
            try? fm.copyItem(at: source, to: destination)
        }
    }

    private var stickiesURL: URL { baseURL.appendingPathComponent("stickies.json") }
    private var dashboardURL: URL { baseURL.appendingPathComponent("dashboard.json") }
    private var projectsURL: URL { baseURL.appendingPathComponent("projects.json") }

    func loadStickies() -> [StickyNoteModel] {
        guard let data = try? Data(contentsOf: stickiesURL) else { return [] }
        return (try? JSONDecoder().decode([StickyNoteModel].self, from: data)) ?? []
    }

    func saveStickies(_ stickies: [StickyNoteModel]) {
        do {
            let data = try JSONEncoder().encode(stickies)
            try data.write(to: stickiesURL, options: .atomic)
        } catch {
            NSLog("StickyBloom: failed to save stickies.json: \(error)")
        }
    }

    func loadDashboardSettings() -> DashboardSettingsModel {
        guard let data = try? Data(contentsOf: dashboardURL) else { return DashboardSettingsModel() }
        return (try? JSONDecoder().decode(DashboardSettingsModel.self, from: data)) ?? DashboardSettingsModel()
    }

    func saveDashboardSettings(_ settings: DashboardSettingsModel) {
        do {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: dashboardURL, options: .atomic)
        } catch {
            NSLog("StickyBloom: failed to save dashboard.json: \(error)")
        }
    }

    func loadProjects() -> [ProjectModel] {
        guard let data = try? Data(contentsOf: projectsURL) else { return [] }
        return (try? JSONDecoder().decode([ProjectModel].self, from: data)) ?? []
    }

    func saveProjects(_ projects: [ProjectModel]) {
        do {
            let data = try JSONEncoder().encode(projects)
            try data.write(to: projectsURL, options: .atomic)
        } catch {
            NSLog("StickyBloom: failed to save projects.json: \(error)")
        }
    }
}
