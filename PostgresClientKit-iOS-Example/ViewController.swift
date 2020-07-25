//
//  ViewController.swift
//  PostgresClientKit-iOS-Example
//
//  Copyright 2019 David Pitfield and the PostgresClientKit contributors
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import PostgresClientKit
import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    
    // Injected by SceneDelegate.
    var model: Model!
    
    // The text field for the city name.
    @IBOutlet var textField: UITextField!
    
    // The table view containing the weather history.
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        textField.text = "San Francisco"
        showWeatherHistory()
    }

    // Called when the "Show" button is tapped.
    @IBAction func showWeatherHistory() {
        view.endEditing(true)
        let city = textField.text?.trimmingCharacters(in: [" "]) ?? ""
        
        model.weatherHistoryForCity(city) { result in
            do {
                self.weatherHistory = try result.get()
                self.tableView.reloadData()
            } catch {
                // Better error handling goes here...
                Postgres.logger.severe("Error getting weather history: \(String(describing: error))")
            }
        }
    }
    
    
    //
    // MARK: UITableViewDataSource
    //

    var weatherHistory = [Model.Weather]()
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return weatherHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell") ??
            UITableViewCell(style: .subtitle, reuseIdentifier: "WeatherCell")
        
        let weather = weatherHistory[indexPath.row]
        let text = String(describing: weather.date)
        var detailText = "\(weather.lowTemperature) - \(weather.highTemperature) degrees F"
        
        if let precipitation = weather.precipitation {
            detailText += "; \(precipitation) inches of precipitation"
        } else {
            detailText += "; unknown precipitation"
        }

        cell.textLabel?.text = text
        cell.detailTextLabel?.text = detailText
        
        return cell
    }
}

// EOF
