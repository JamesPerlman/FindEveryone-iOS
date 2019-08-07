//
//  LocationService.swift
//  FindEveryone
//
//  Created by James Perlman on 8/5/19.
//  Copyright © 2019 Salida Media. All rights reserved.
//

import CoreLocation
import Foundation
import RxCoreLocation
import RxRelay
import RxSwift

class LocationService {
    
    private let rxBag = DisposeBag()
    fileprivate let locationManager = CLLocationManager()
    
    var authorizationStatus = BehaviorRelay<CLAuthorizationStatus>(value: .notDetermined)
    var isAuthorized = BehaviorRelay(value: false)
    var location = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
    
    init() {
        authorizationStatus
            .map({ status -> Bool in
                status.isAuthorized
            })
            .asDriver(onErrorJustReturn: false)
            .drive(isAuthorized)
            .disposed(by: rxBag)

        locationManager.rx
            .didChangeAuthorization
            .map({ (_, status) -> CLAuthorizationStatus in
                status
            })
            .asDriver(onErrorJustReturn: .notDetermined)
            .drive(authorizationStatus)
            .disposed(by: rxBag)
        
        locationManager.rx
            .location
            .asDriver(onErrorJustReturn: nil)
            .map({ location -> CLLocationCoordinate2D? in
                location?.coordinate
            })
            .drive(location)
            .disposed(by: rxBag)
    }
    
    func enableLocationServices() {
        // locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}
