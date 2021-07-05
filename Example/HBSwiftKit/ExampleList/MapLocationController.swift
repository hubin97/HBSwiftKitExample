//
//  MapLocationController.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/7/2.
//  Copyright © 2020 Wingto. All rights reserved.

import UIKit
import Foundation
import CoreLocation
import MapKit

//MARK: - global var and methods

//MARK: - main class
class MapLocationController: BaseViewController {
    
    lazy var locManager: CLLocationManager = {
        let _locManager = CLLocationManager.init()
        _locManager.delegate = self
        return _locManager
    }()
    
    lazy var mapView: MKMapView = {
        let _mapView = MKMapView.init(frame: view.bounds)
        _mapView.delegate = self
        return _mapView
    }()
    
    override func setupUi() {
        super.setupUi()
        self.navigationItem.title = "定位"
        
        view.addSubview(mapView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AuthStatus.locationServices {[weak self] (status) in
            print("定位权限\(status ? "on": "off")")
            self?.startLocation()
        }
    }
}

//MARK: - private mothods
extension MapLocationController {
    
}

//MARK: - call backs
extension MapLocationController {
    
}

//MARK: - delegate or data source
extension MapLocationController: MKMapViewDelegate, AuthStatusLocationDelegate {
 
    /// 辅助弹框提示
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations---")
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError---")
    }
}

//MARK: - other classes
