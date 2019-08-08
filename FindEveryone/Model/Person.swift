//
//  Person.swift
//  FindEveryone
//
//  Created by James Perlman on 8/6/19.
//  Copyright © 2019 Salida Media. All rights reserved.
//

import Firebase
import Foundation

struct Person: Codable {
    let location: GeoPoint
    let time: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case location
        case time
    }
}
