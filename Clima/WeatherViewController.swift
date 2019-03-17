//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation // module that enables us to use GPS functionality of device
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "96b6e8e55a1996ab3e1e878d70ba6667"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager() // initialize location manager
    let weatherDataModel = WeatherDataModel() // initialize weather data model object

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self // set delegate value to WeatherViewController class
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // set desired accuracy value to 100 meters (best accuracy is not needed for this app because the weather won't be very different from the user's position to 100 meters radius & specifying 100 meter accuracy drains less battery)
        locationManager.requestWhenInUseAuthorization() // method that triggers authorization pop-up to request location data when app is in use
        locationManager.startUpdatingLocation() // method that triggers location manager to begin searching for device location (ASYNC METHOD: happens in background)
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    // method that retrieves weather data
    func getWeatherData(url: String, parameters: [String: String]) {
        // Async request
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            // check if response contains result that was successful
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                let weatherJSON: JSON = JSON(response.result.value!) // safe to force unwrap because the result has already been checked to see if it was successful
                self.updateWeatherData(json: weatherJSON) // call method that updates weather data (specify .self when inside a closure statement)
                
                
                
            } else {
                print("Error \(response.result.error ?? "Unable to retrieve error!" as! Error)")
                self.cityLabel.text = "Connection Issues"
            } // end if-else statement
        
        } // end Alamofire request
        
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    // method that updates weather data
    func updateWeatherData(json: JSON) {
        
        // use optional binding to check if value retrieved is not nil
        if let tempResult = json["main"]["temp"].double {
        
        weatherDataModel.temperature = Int(((tempResult - 273.15) * (9/5)) + 32) // use math to convert from Kelvin to Farenheit (Americans, am I right?)
        
        weatherDataModel.city = json["name"].stringValue // convert city name value from JSON to String and set value in weather data model object
        
        weatherDataModel.condition = json["weather"][0]["id"].intValue // convert condition value from JSON to Int and set value in weather data model object
        
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition) // call method that outputs name of icon image to display and set value to weather data model object
            
            updateUIWeatherData() // call method to update user interface
            
        } else {
            cityLabel.text = "Weather Unavailable" // set value to error description when unable to retrieve valuable data
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWeatherData() {
        
        cityLabel.text = weatherDataModel.city // set value to corresponding city name
        
        temperatureLabel.text = "\(weatherDataModel.temperature)°" // set value to corresponding temperature value
        
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName) // set value to corresponding weather icon image
        
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    // method that gets activated once location manager has found a location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1] // retrieve most accurate location in array (last location in array will be the most accurate)
        
        // check to make sure the value retrieved is valid
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation() // call method to stop searching for a new location (drains less battery)
            locationManager.delegate = nil // set locationManager delegate to nil to prevent retrieving data multiple times
            
            print("Longitude: = \(location.coordinate.longitude), Latitude: \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude) // initialize and declare latitude coordinates as a String type
            let longitude = String(location.coordinate.longitude) // initialize and declare longitude coordinates as a String type
            
            let params: [String : String] = ["lat": latitude, "lon": longitude, "appid": APP_ID] // initialize and declare parameters in dictionary-style array
            
            getWeatherData(url: WEATHER_URL, parameters: params) // call method that retrieves weather data
        }
        
    }
    
    
    //Write the didFailWithError method here:
    // method that gets activated when location manager could not find a location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    // protocol method required
    func userEnteredANewCityName(city: String) {
        
        let params: [String: String] = ["q": city, "appid": APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }

    
    //Write the PrepareForSegue Method here
    // method that gets triggered when the view controller is changed through a segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // execute if segue identifier is valid "changeCityName" segue
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController // initialize segue destination and set value to ChangeCityViewController data type
            
            destinationVC.delegate = self // set current view controller as the delegate to recieve data
            
        }
        
    }
    
    
    
    
}


