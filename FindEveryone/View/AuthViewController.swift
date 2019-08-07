//
//  AuthViewController.swift
//  FindEveryone
//
//  Created by James Perlman on 8/5/19.
//  Copyright © 2019 Salida Media. All rights reserved.
//

import UIKit
import RxSwift

class AuthViewController: UIViewController {
    
    @IBOutlet var authButton: UIButton!
    
    let locationService = LocationService()
    let authService = AuthenticationService()
    let rxBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authService
            .isAuthenticated
            .filter({ $0 == true })
            .subscribe(onNext: { [weak self] _ in
                self?.locationService.enableLocationServices()
            })
            .disposed(by: rxBag)
        
        Observable
            .combineLatest(authService.isAuthenticated,
                           locationService.isAuthorized,
                           resultSelector: { (signedIn, locationAuthorized) -> Bool in
                            signedIn == true && locationAuthorized == true
            })
            .filter({ $0 == true })
            .take(1)
            .subscribe(onNext: { [weak self] isAuthorized in
                self?.performSegue(withIdentifier: "toMap", sender: self)
            })
            .disposed(by: rxBag)
    }
    
    @IBAction func authenticate(_ sender: UIButton) {
        authService.authenticate()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toMap" {
            guard let vc = segue.destination as? MapViewController else {
                return
            }
            vc.firebaseService = FirebaseService(authService: authService, locationService: locationService)
        }
    }
    
}
