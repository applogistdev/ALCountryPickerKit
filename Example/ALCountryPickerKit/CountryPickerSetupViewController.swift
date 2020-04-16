//
//  ViewController.swift
//  ALCountryPicker
//
//  Created by sonifex on 04/01/2020.
//  Copyright (c) 2020 sonifex. All rights reserved.
//

import UIKit
import ALCountryPickerKit

class CountryPickerSetupViewController: UIViewController {
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var languageSegmented: UISegmentedControl!
    @IBOutlet weak var sectionTypeSegmented: UISegmentedControl!
    @IBOutlet weak var presentationTypeSegmented: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            [languageSegmented, sectionTypeSegmented, presentationTypeSegmented].forEach {
                $0?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
            }
        }
    }
    
    @IBAction func buttonTapped(_ button: UIButton) {
        navigateToCountrySelection()
    }
    
    func config() -> ALCountryPickerConfig {
        let conf = ALCountryPickerConfig()
        conf.sectionEnabled = sectionTypeSegmented.selectedSegmentIndex == 0
        // conf.searchBarTintColor = .brown
        // conf.searchBarTextColor = .orange // Can be set if wanted
        return conf
    }
    
    func locale() -> Locale {
        switch languageSegmented.selectedSegmentIndex {
            case 0:
                return Locale(identifier: "en-US")
            case 1:
                return Locale(identifier: "tr-TR")
            case 2:
                return Locale(identifier: "de-DE")
            default:
                return Locale(identifier: "tr-TR")
        }
    }
    
    func navigateToCountrySelection() {
        
        let picker = ALCountryPicker(locale: locale(),
                                     config: config())
        
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

extension CountryPickerSetupViewController: ALCountryPickerDelegate {
    func countryPicker(picker: ALCountryPicker, didSelect country: ALCountry) {
        countryLabel.text = country.name
    }
}

