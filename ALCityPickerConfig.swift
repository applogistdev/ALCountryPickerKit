//
//  ALCityPickerConfig.swift
//  ALCountryPickerKit
//
//  Created by Unal Celik on 16.04.2020.
//

import Foundation

public class ALCityPickerConfig {
    public var cellTitleFont: UIFont = .systemFont(ofSize: 14)
    public var cellDetailFont: UIFont = .systemFont(ofSize: 12)
    public var cellRowHeight: CGFloat = 45
    public var searchEnabled: Bool = true
    
    public var searchBarTintColor: UIColor = .white
    public var searchBarTextColor: UIColor?
    
    public init() { }
}
