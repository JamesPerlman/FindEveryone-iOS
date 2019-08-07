//
//  CLLocationCoordinate2D+GeoPoint.swift
//  FindEveryone
//
//  Created by James Perlman on 8/6/19.
//  Copyright © 2019 Salida Media. All rights reserved.
//

import CoreLocation
import Firebase
import Foundation

extension GeoPoint {
    convenience init(_ coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude,
                  longitude: coordinate.longitude)
    }
}

extension CLLocationCoordinate2D {
    init(_ geoPoint: GeoPoint) {
        self.init(latitude: geoPoint.latitude,
                  longitude: geoPoint.longitude)
    }
}
