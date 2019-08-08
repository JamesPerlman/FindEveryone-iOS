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
import SwiftKeychainWrapper

let AUTH_TOKEN_KEY = "token"

class AuthenticationService {
    
    private lazy var auth = Auth.auth()
    private var keychain = KeychainWrapper.standard
    
    var uid = BehaviorRelay<String?>(value: nil)
    var token = BehaviorRelay<String?>(value: nil)
    var isAuthenticated = BehaviorRelay(value: false)
    
    let rxBag = DisposeBag()
    
    init() {
        restoreTokenFromKeychain()
        
        uid
            .map({ value -> Bool in
                value != nil
            })
            .asDriver(onErrorJustReturn: false)
            .drive(isAuthenticated)
            .disposed(by: rxBag)
        
        token
            .asObservable()
            .subscribe(onNext: { [weak self] (tokenString) in
                if let tokenString = tokenString {
                    self?.keychain.set(tokenString, forKey: AUTH_TOKEN_KEY)
                } else {
                    self?.keychain.removeObject(forKey: AUTH_TOKEN_KEY)
                }
            })
            .disposed(by: rxBag)
    }
    
    func authenticate() {
        Auth.auth().signInAnonymously { [weak self] (result, error) in
            guard let result = result else {
                return
            }
            
            guard let sself = self else {
                return
            }
            
            sself.uid.accept(result.user.uid)
            if sself.token.value == nil {
                sself.token.accept(result.user.uid)
            }
        }
    }
    
    private func restoreTokenFromKeychain() {
        setToken(keychain.string(forKey: AUTH_TOKEN_KEY))
    }
    
    private func saveTokenToKeychain(_ token: String) {
        keychain.set(token, forKey: AUTH_TOKEN_KEY)
    }
    
    func setToken(_ tokenString: String?) {
        token.accept(tokenString)
    }
}
