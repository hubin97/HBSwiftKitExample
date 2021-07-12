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
    
    /// 当前位置
    var curLocation: CLLocation?
    lazy var locManager: CLLocationManager = {
        let _locManager = CLLocationManager.init()
        _locManager.delegate = self
        _locManager.desiredAccuracy = 1000//1.0 // 精度以米为单位, >0
        return _locManager
    }()
    
    lazy var mapView: MKMapView = {
        let _mapView = MKMapView.init(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH - kNavBarAndSafeHeight - kBottomSafeHeight))
        _mapView.delegate = self
        _mapView.showsUserLocation = true
        _mapView.userTrackingMode = .follow
        _mapView.showsScale = true // 比例尺
        return _mapView
    }()
    
    lazy var focusBtn: UIButton = {
        let _focusBtn = UIButton.init(type: .custom)
        _focusBtn.frame = CGRect(x: 20, y: kScreenH - kNavBarAndSafeHeight - kBottomSafeHeight - 20 - 40, width: 40, height: 40)
        _focusBtn.setBackgroundImage(UIImage(color: .white), for: .normal)
        _focusBtn.setRoundCorners(borderColor: .systemBlue, borderWidth: 0.5, raddi: 20, corners: .allCorners, isDotted: true, lineDashPattern: [4, 2])
        _focusBtn.setTitle("+", for: .normal)
        _focusBtn.setTitleColor(.systemBlue, for: .normal)
        _focusBtn.addTarget(self, action: #selector(focusAtion), for: .touchUpInside)
        return _focusBtn
    }()
    
    lazy var poiBtn: UIButton = {
        let _poiBtn = UIButton.init(type: .custom)
        _poiBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        //_poiBtn.setBackgroundImage(UIImage(color: .white), for: .normal)
        //_poiBtn.setRoundCorners(borderColor: .systemBlue, borderWidth: 0.5, raddi: 20, corners: .allCorners, isDotted: true, lineDashPattern: [4, 2])
        _poiBtn.setTitle("🔍", for: .normal)
        _poiBtn.setTitleColor(.systemBlue, for: .normal)
        _poiBtn.addTarget(self, action: #selector(poiSearchAtion), for: .touchUpInside)
        return _poiBtn
    }()
    
    override func setupUi() {
        super.setupUi()
        self.navigationItem.title = "定位"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: poiBtn)
        view.addSubview(mapView)
        view.addSubview(focusBtn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AuthStatus.locationServices {[weak self] (status) in
            print("定位权限\(status ? "on": "off")")
            self?.wakeupAuthAlert()
        }
    }
    
    @objc func focusAtion() {
        self.locManager.requestLocation()
        self.locManager.startUpdatingLocation()
    }
    
    @objc func poiSearchAtion() {
        guard let location = self.curLocation else { return }
        self.poiSearch(location: location, keyword: "侨城北")
    }
}

//MARK: - private mothods
extension MapLocationController {
 
    func poiSearch(location: CLLocation, keyword: String) {
        //let span = MKCoordinateSpanMake(0.01, 0.01)
        let span = MKCoordinateSpanMake(1000, 1000)
        let localSearchReq = MKLocalSearchRequest.init()
        let region = MKCoordinateRegionMake(location.coordinate, span)
        
        localSearchReq.region = region
        localSearchReq.naturalLanguageQuery = keyword
        let localSearch = MKLocalSearch.init(request: localSearchReq)
        localSearch.start { (response, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                guard let result = response else { return }
                for mapItem in result.mapItems {
                    print("==> \(mapItem)")
                    
                    let tmplocation = mapItem.placemark.location
                    print("==> \(tmplocation ?? CLLocation())")
                }
            }
        }

    }
}

//MARK: - call backs
extension MapLocationController {
    
}

//MARK: - delegate or data source
extension MapLocationController: MKMapViewDelegate, AuthStatusLocationDelegate, CLLocationManagerDelegate {
 
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("didUpdateLocations---\(locations)")
        self.curLocation = locations.last
        self.mapView.setCenter(locations.last?.coordinate ?? CLLocationCoordinate2D(), animated: true)
        //self.poiSearch(location: locations.first!, keyword: "侨城北")
        self.locManager.stopUpdatingLocation()
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError---")
    }
}

//MARK: - other classes
//poi检索列表
class POIRspListController: BaseViewController {
    
    override func setupUi() {
        super.setupUi()
        self.navigationItem.title = "周边检索列表"
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(qureAction))
        
    }
    
    @objc func qureAction() {
        
    }
}
