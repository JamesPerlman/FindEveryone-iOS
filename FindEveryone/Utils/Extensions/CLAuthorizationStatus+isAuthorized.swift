//
//  CLAuthorizationStatus+isAuthorized.swift
//  FindEveryone
//
//  Created by James Perlman on 8/5/19.
//  Copyright © 2019 Salida Media. All rights reserved.
//

import CoreLocation
import Foundation

extension CLAuthorizationStatus {
    var isAuthorized: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            return false
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        @unknown default:
            return false
        }
    }
}
