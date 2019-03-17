//
//  ChangeCityViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit


//Write the protocol declaration here:
// protocol that specifies the controller needs to have the required method
protocol ChangeCityDelegate {
    func userEnteredANewCityName (city: String)
}


class ChangeCityViewController: UIViewController {
    
    //Declare the delegate variable here:
    var delegate: ChangeCityDelegate?
    
    //This is the pre-linked IBOutlets to the text field:
    @IBOutlet weak var changeCityTextField: UITextField!

    
    //This is the IBAction that gets called when the user taps on the "Get Weather" button:
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        
        
        
        //1 Get the city name the user entered in the text field
        let cityName = changeCityTextField.text ?? "" // set value to city name entered
        
        //2 If we have a delegate set, call the method userEnteredANewCityName
        delegate?.userEnteredANewCityName(city: cityName) // execute if delegate is valid (was set)
        // ? is called optional chaining - it checks if delegate contains a value or if it is nil, if it contains a value, execute the method else ignore it entirely
        
        //3 dismiss the Change City View Controller to go back to the WeatherViewController
        self.dismiss(animated: true, completion: nil) //
        
    }
    
    

    //This is the IBAction that gets called when the user taps the back button. It dismisses the ChangeCityViewController.
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
