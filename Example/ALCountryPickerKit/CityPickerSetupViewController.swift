//
//  ViewController.swift
//  ALCountryPicker
//
//  Created by sonifex on 04/01/2020.
//  Copyright (c) 2020 sonifex. All rights reserved.
//

import UIKit
import ALCountryPickerKit

class CityPickerSetupViewController: UIViewController {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var presentationTypeSegmented: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func buttonTapped(_ button: UIButton) {
        navigateToCitySelection()
    }
    
    func config() -> ALCityPickerConfig {
        let conf = ALCityPickerConfig()
        // Configurations..
        
        // conf.searchBarTintColor = .brown
        // conf.searchBarTextColor = .orange
        return conf
    }
    
    func navigateToCitySelection() {
        let picker = ALCityPicker(config: config())
        
        picker.delegate = self
        
        if presentationTypeSegmented.selectedSegmentIndex == 0 {
            let navVC = UINavigationController(rootViewController: picker)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true, completion: nil)
        } else {
            self.navigationController?.pushViewController(picker,
                                                          animated: true)
        }
    }
}

extension CityPickerSetupViewController: ALCityPickerDelegate {
    func cityPicker(picker: ALCityPicker, didSelect city: ALCity) {
        cityLabel.text = city.name
    }
}

