//
//  BDLocationManager.swift
//  ResourceManager
//
//  Created by 李智慧 on 25/04/2017.
//  Copyright © 2017 北京海睿兴业. All rights reserved.
//
import MapKit
import RxCocoa
import RxSwift
import Moya

public typealias AMSearchCompletionHandler = ([AMapPOI]) -> Void

public typealias AMLocationCompletionHandler = (CLLocation) -> Void

open class PFSLocationManager: NSObject, AMapSearchDelegate, AMapLocationManagerDelegate {
    var search: AMapSearchAPI?
    
    var locationManager = AMapLocationManager()
    
    var location = PublishSubject<CLLocation>()
    
    
    var locationCompletionHandler: AMLocationCompletionHandler?
    
    var searchCompletionHandler: AMSearchCompletionHandler?
    
    public override init() {
        super.init()
        AMapServices.shared().apiKey = "4a677acff506f75571a0b45178b1c4e2"
        self.locationManager.distanceFilter = 200
    }
    
    
    open func startUpdatingLocation() -> Driver<CLLocation>  {
        self.locationManager.startUpdatingLocation()

        self.locationManager.delegate = self
        
        let location = CLLocation(latitude: kCLLocationCoordinate2DInvalid.latitude, longitude: kCLLocationCoordinate2DInvalid.longitude)
        
        self.location = PublishSubject<CLLocation>()
                
        return self.location.asObservable().asDriver(onErrorJustReturn: location)
    }
    
    public func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Swift.Error!) {
        self.location.onError(MoyaError.underlying(error))
        self.locationManager.stopUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
        self.locationManager.delegate = nil
    }

    
    open func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!) {
        if let locationCompletionHandler = self.locationCompletionHandler {
            locationCompletionHandler(location)
        }
        self.stopUpdatingLocation()
        self.location.onNext(location)
        self.location.onCompleted()
    }
    
    open func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if let searchCompletionHandler = self.searchCompletionHandler {
            searchCompletionHandler(response.pois)
        }
    }
    
    deinit {
        self.stopUpdatingLocation()
        self.location.onCompleted()
    }

}
