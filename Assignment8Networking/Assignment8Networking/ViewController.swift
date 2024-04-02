//
//  ViewController.swift
//  Assignment8Networking
//
//  Created by user238294 on 3/28/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var lblcity: UILabel!
    @IBOutlet weak var lbldescription: UILabel!
    @IBOutlet weak var lblimgview: UIImageView!
    @IBOutlet weak var lbltemperature: UILabel!
    @IBOutlet weak var lblhumidity: UILabel!
    
    @IBOutlet weak var lblwindspeed: UILabel!
    
    
    let GPSManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GPSManager.delegate = self
        GPSManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            GPSManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            getDataFromAPI(lat: location.coordinate.latitude, lon: location.coordinate.longitude) { [weak self] result in
                switch result {
                case .success(let success):
                    DispatchQueue.main.async {
                        self?.updateUI(data: success)
                    }
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func updateUI(data: WeatherData) {
        lblcity.text = data.name ?? ""
        lbldescription.text = data.weather?.first?.description ?? ""
        if let weatherurl = URL(string: "https://openweathermap.org/img/wn/\(data.weather?.first?.icon ?? "")@2x.png") {
            lblimgview.load(url: weatherurl)
        }
        lblhumidity.text = "Humidity: \(data.main?.humidity ?? 0)"
        lblwindspeed.text = "Wind: \(data.wind?.speed ?? 0)Km/h"
        lbltemperature.text = "\(Int(data.main?.temp ?? 0))°C"
    }
    
    func getDataFromAPI(lat: Double, lon: Double, completion: @escaping (Result<WeatherData, Error>) -> ()) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=6554c931b0421b176988b8a39861a37a&units=metric") else { return }
        URLSession.shared.dataTask(with: URLRequest(url: url)) { jsonData, _, error in
            guard let jsonData = jsonData else { return }
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: jsonData)
                completion(.success(weatherData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

