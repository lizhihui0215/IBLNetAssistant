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
        AMapServices.sharedServices().apiKey = "4a677acff506f75571a0b45178b1c4e2"
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 200
    }
    
    
    open func startUpdatingLocation() -> Driver<CLLocation>  {
        self.locationManager.startUpdatingLocation()
        
        let location = CLLocation(latitude: kCLLocationCoordinate2DInvalid.latitude, longitude: kCLLocationCoordinate2DInvalid.longitude)
        
        return self.location.asObservable().asDriver(onErrorJustReturn: location)
    }
    
//    open func search(query: String = "", page: Int, count: Int, completionHandler: @escaping AMSearchCompletionHandler)  {
//        self.searchCompletionHandler = completionHandler
//        self.startUpdatingLocation {[weak self] location in
//            
//            let request = AMapPOIAroundSearchRequest()
//            if let strongSelf = self {
//                strongSelf.search = AMapSearchAPI()
//                strongSelf.search?.delegate = self
//                strongSelf.locationManager.stopUpdatingLocation()
//                request.location = AMapGeoPoint.location(withLatitude: CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.longitude))
//                request.keywords = query
//                request.page = page
//                request.offset = count
//                request.requireExtension = true
//                strongSelf.search?.aMapPOIAroundSearch(request)
//            }
//        }
//    }
    
    open func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!) {
        if let locationCompletionHandler = self.locationCompletionHandler {
            locationCompletionHandler(location)
        }
        
        self.location.onNext(location)
        self.location.onCompleted()
    }
    
    open func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if let searchCompletionHandler = self.searchCompletionHandler {
            searchCompletionHandler(response.pois)
        }
    }
    
    deinit {
        self.locationManager.stopUpdatingLocation()
    }

}
