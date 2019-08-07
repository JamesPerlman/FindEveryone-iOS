//
//  AuthenticationService.swift
//  FindEveryone
//
//  Created by James Perlman on 8/5/19.
//  Copyright © 2019 Salida Media. All rights reserved.
//

import Firebase
import Foundation
import RxSwift
import RxRelay

class AuthenticationService {
    
    private lazy var auth = Auth.auth()
    
    var uid = BehaviorRelay<String?>(value: nil)
    var isAuthenticated = BehaviorRelay(value: false)
    
    let rxBag = DisposeBag()
    
    init() {
        uid
            .map({ value -> Bool in
                value != nil
            })
            .asDriver(onErrorJustReturn: false)
            .drive(isAuthenticated)
            .disposed(by: rxBag)
    }
    
    func authenticate() {
        Auth.auth().signInAnonymously { [weak self] (result, error) in
            guard let result = result else {
                return
            }
            
            self?.uid.accept(result.user.uid)
        }
    }
}
