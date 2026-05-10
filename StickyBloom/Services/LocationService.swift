import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject {
    @Published var cityName: String?
    @Published var detectedTimeZoneIdentifier: String?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var lastLocation: CLLocation?

    private static let cityKey = "LocationService.cachedCity"
    private static let tzKey = "LocationService.cachedTimeZone"

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        cityName = UserDefaults.standard.string(forKey: Self.cityKey)
        detectedTimeZoneIdentifier = UserDefaults.standard.string(forKey: Self.tzKey)
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        switch manager.authorizationStatus {
        case .authorized, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            requestAuthorization()
        }
    }

    private func reverseGeocode(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self else { return }
            let placemark = placemarks?.first
            let city = placemark?.locality
            let tzID = placemark?.timeZone?.identifier
            Task { @MainActor in
                if let city {
                    self.cityName = city
                    UserDefaults.standard.set(city, forKey: Self.cityKey)
                }
                if let tzID {
                    self.detectedTimeZoneIdentifier = tzID
                    UserDefaults.standard.set(tzID, forKey: Self.tzKey)
                }
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.lastLocation = location
            self.reverseGeocode(location)
            manager.stopUpdatingLocation()
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorized || manager.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }
}
