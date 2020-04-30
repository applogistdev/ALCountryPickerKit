//
//  ALCity.swift
//  ALCountryPickerKit
//
//  Created by Unal Celik on 16.04.2020.
//

import Foundation

public struct ALCity: Comparable {
    public let name: String
    public let plateCode: Int
    
    public static func < (lhs: ALCity, rhs: ALCity) -> Bool {
        lhs.plateCode < rhs.plateCode
    }
}
