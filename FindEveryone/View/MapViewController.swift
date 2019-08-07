//
//  ViewController.swift
//  FindEveryone
//
//  Created by James Perlman on 8/5/19.
//  Copyright © 2019 Salida Media. All rights reserved.
//

import MapKit
import RxCocoa
import RxMKMapView
import RxSwift
import UIKit

class MapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!

    var firebaseService: FirebaseService?
    
    let rxBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.hidesBackButton = true
        
        mapView.rx
            .setDelegate(self)
            .disposed(by: rxBag)
        
        firebaseService?
            .everyone
            .asObservable()
            .map({ everyone -> [MKAnnotation] in
                everyone.map({ person -> MKAnnotation in
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(person.location)
                    return annotation
                })
            })
            .asDriver(onErrorJustReturn: [])
            .drive(mapView.rx.annotations)
            .disposed(by: rxBag)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MKPointAnnotation else {
            return nil
        }
        
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "person")
        return view
    }
}
