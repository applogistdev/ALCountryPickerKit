//
//  ALSectionedCountries.swift
//  ALCountryPicker
//
//  Created by Soner Güler on 1.04.2020.
//  Copyright © 2020 Applogist. All rights reserved.
//

import Foundation

struct ALSectionedCountries: Comparable {
    let title: String
    let countries: [ALCountry]
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        
        return lhs.title.compare(rhs.title,
                                 options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive],
                                 range: nil,
                                 locale: .current) == .orderedAscending
    }
}
