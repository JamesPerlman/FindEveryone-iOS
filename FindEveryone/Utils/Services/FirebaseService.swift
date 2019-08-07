//
//  FirebaseService.swift
//  FindEveryone
//
//  Created by James Perlman on 8/6/19.
//  Copyright © 2019 Salida Media. All rights reserved.
//

import CodableFirebase
import CoreLocation
import Firebase
import FirebaseFirestore
import Foundation
import RxRelay
import RxSwift

class FirebaseService {
    
    private let authService: AuthenticationService
    private let locationService: LocationService
    
    private let rxBag = DisposeBag()
    private lazy var firestore = Firestore.firestore()
    private let firestoreDecoder = FirestoreDecoder()
    
    var personExists = BehaviorRelay<Bool>(value: false)
    var everyone = BehaviorRelay<[Person]>(value: [])
    
    init(authService: AuthenticationService, locationService: LocationService) {
        self.authService = authService
        self.locationService = locationService
        
        // auth service uid creates new user (if one doesn't already exist)
        let uid = authService
            .uid
            .asObservable()
            .notNil()
            .share(replay: 1, scope: .whileConnected)
        
        let myCoords = locationService
            .location
            .asObservable()
            .notNil()
            .share(replay: 1, scope: .whileConnected)
        
        // update my person model when uid or location changes
        Observable
            .combineLatest(uid, myCoords)
            .subscribe(onNext: { [weak self] (uid, coords) in
                self?.updatePerson(uid, coords)
            })
            .disposed(by: rxBag)
        
        // get realtime updates on ...everyone
        firestore
            .collection("everyone")
            .addSnapshotListener { [weak self] (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Error getting everyone. \(error?.localizedDescription ?? "No error.")")
                    return
                }
                let everyone = snapshot.documents
                    .map({ document -> Person? in
                        var data = document.data()
                        return try? self?.firestoreDecoder.decode(Person.self, from: data)
                    })
                    .compactMap({ $0 })
                
                self?.everyone.accept(everyone)
        }
    }
    
    func updatePerson(_ uid: String, _ coords: CLLocationCoordinate2D) {
        firestore
            .collection("everyone")
            .document(uid)
            .setData([ "location" : GeoPoint(coords) ], completion: { [weak self] (error) in
                self?.personExists.accept(error == nil)
            })
    }
}
