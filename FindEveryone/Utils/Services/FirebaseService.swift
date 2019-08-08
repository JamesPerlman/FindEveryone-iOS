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
import RxSwiftExt

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
        let token = authService
            .token
            .asObservable()
            .share(replay: 1, scope: .whileConnected)
        
        let myCoords = locationService
            .location
            .asObservable()
            .unwrap()
            .share(replay: 1, scope: .whileConnected)
        
        // stream describing token only if token is nil AND token not changing from nil to String
        let tokenChange = token
            .startWith(nil)
            .pairwise()
            .filter({ prevToken, token in
                (prevToken == nil && token == nil)
                || (prevToken != nil && token != nil)
            })
            .map({ _, token in
                token
            })
        
        // first token triggers createOrUpdatePerson
        token
            .take(1)
            .withLatestFrom(myCoords, resultSelector: { ($0, $1) })
            .subscribe(onNext: { [weak self] (token, coords) in
                self?.createOrUpdatePerson(token, coords)
            })
            .disposed(by: rxBag)
        
        // update my person model when location changes
        Observable
            .combineLatest(tokenChange, myCoords)
            .subscribe(onNext: { [weak self] (token, coords) in
                self?.createOrUpdatePerson(token, coords)
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
                        return try? self?.firestoreDecoder.decode(Person.self, from: document.data())
                    })
                    .compactMap({ $0 })
                
                self?.everyone.accept(everyone)
        }
    }
    
    func createOrUpdatePerson(_ token: String?, _ coords: CLLocationCoordinate2D) {
        if let token = token {
            updatePerson(token, coords)
        } else {
            createPerson(coords)
        }
    }
    
    func createPerson(_ coords: CLLocationCoordinate2D) {
        let person = firestore
            .collection("everyone")
            .document()
        
        let myData = getMyDataDict(coords: coords)
            
        person
            .setData(myData, completion: { [weak self] (error) in
                guard let sself = self, error == nil else {
                    print("Unable to set data for newly created person.  \(error?.localizedDescription ?? "No error.")")
                    return
                }
                sself.personExists.accept(error == nil)
                sself.authService.setToken(person.documentID)
            })
    }
    
    func updatePerson(_ token: String, _ coords: CLLocationCoordinate2D) {
        let myData = getMyDataDict(coords: coords)
        
        firestore
            .collection("everyone")
            .document(token)
            .setData(myData, completion: { [weak self] (error) in
                self?.personExists.accept(error == nil)
            })
    }
    
    private func getMyDataDict(coords: CLLocationCoordinate2D) -> [String : Any] {
        return [
            "location" : GeoPoint(coords),
            "time" : Timestamp(date: Date())
        ]
    }
}
