//
//  ALCountry.swift
//  ALCountryPicker
//
//  Created by Soner Güler on 1.04.2020.
//  Copyright © 2020 Applogist. All rights reserved.
//

import Foundation

public struct ALCountry: Comparable {
    public let name: String
    public let isoCode: String
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        
        return lhs.name.compare(rhs.name,
                                options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive],
                                range: nil,
                                locale: .current) == .orderedAscending
    }
}
