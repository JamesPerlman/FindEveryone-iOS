//
//  LocationService.swift
//  FindEveryone
//
//  Created by James Perlman on 8/5/19.
//  Copyright © 2019 Salida Media. All rights reserved.
//

import CoreLocation
import Foundation
import RxCocoa
import RxCoreLocation
import RxSwift

class LocationService {
    
    let rxBag = DisposeBag()
    let locationManager = CLLocationManager()
    
    var authorizationStatus = BehaviorRelay<CLAuthorizationStatus>(value: .notDetermined)
    var isAuthorized = BehaviorRelay(value: false)
    
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
    
    init() {
        locationManager.rx
            .didChangeAuthorization
            .map({ (_, status) -> CLAuthorizationStatus in
                status
            })
            .asDriver(onErrorJustReturn: .notDetermined)
            .drive(authorizationStatus)
            .disposed(by: rxBag)
        
        authorizationStatus
            .map({ status -> Bool in
                switch status {
                    case
                }
            })
        
    }
    
    func enableLocationServices() {
        // locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
