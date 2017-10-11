//
//  IBLDataResponsitory.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 12/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift
import RxSwift
import Result
import Moya
import RxCocoa
import ObjectMapper
import class Alamofire.NetworkReachabilityManager

extension BaseMappable {
    func toJSONRealm() -> [String : Any]? {
        var json: [String: Any]?
        try? PFSRealm.realm.write {
            json = self.toJSON()
        }
        
        return json
    }
}

class IBLDataRepository: PFSDataRepository {

    static let shared = IBLDataRepository()

    func exchangePassword(account: String, phone: String, sms: String, password: String) -> Driver<Result<String, MoyaError>> {
        return self.request(.exchangePassword(account,phone,sms,password))
    }

    private var _school: IBLSchool = IBLSchool()

    func offline(kickurl: String, online: IBLOnline) -> Driver<Result<String, MoyaError>> {
        let result: Single<PFSResponseNil> = PFSNetworkService<IBLAPITarget>.shared.request(.offline(kickurl, online.account!, online.userip!))

        return self.handlerError(response: result)
    }

    var school: IBLSchool{
        get{
            guard _school.serverInner != nil else {
                guard let cachedSchool: IBLSchool = PFSRealm.shared.object() else {
                    return IBLSchool()
                }
                
                _school = cachedSchool

                
                return _school
            }
            return _school
        }
        set {
            _school = newValue
        }
    }

    func sendSMS(account: String, phone: String) -> Driver<Result<String, MoyaError>> {
        return self.request(.sms(account, phone))
    }

    override init() {
        super.init()
    }

    func fetchSchools(locationCoordinate2D: CLLocationCoordinate2D) -> Driver<Result<[IBLSchool], MoyaError>> {
        let result: Single<PFSResponseMappableArray<IBLSchool>> = PFSNetworkService<IBLAPITarget>.shared.request(.school(locationCoordinate2D))

        return self.handlerError(response: result)
    }

    func auth(account: String, password: String) -> Driver<Result<IBLUser, MoyaError>> {
        return self.request(.auth(account, password))
    }

    func register(account: String, school: IBLSchool) -> Driver<Result<String, MoyaError>> {
        return self.request(.register(account,school))
    }
    
    func portal(url: String) -> Driver<Result<PortalAuth, MoyaError>> {
        let result: Single<PFSResponseMappableObject<PortalAuth>> = PFSNetworkService<IBLAPITarget>.shared.request(.portal(url))

        return self.handlerError(response: result)
    }

    func logout(_ account: String, auth: PortalAuth) -> Driver<Result<String, MoyaError>> {
        
        let authJSON = Dictionary<String, Any>.toJSON(JSONObject: auth.JSON!)

        
        let result: Single<PFSResponseNil> = PFSNetworkService<IBLAPITarget>.shared.request(.logout(account,authJSON ?? [:]))

        return self.handlerError(response: result)
    }

    func cachedSchool() -> IBLSchool? {
        guard let cachedSchool: IBLSchool = PFSRealm.shared.object() else {
            return  nil
        }
        
        return cachedSchool
    }

    func portalAuth(account: String, password: String, _ auth: [String: Any]) -> Driver<Result<IBLUser, MoyaError>> {
        let result: Single<PFSResponseMappableObject<IBLUser>> = PFSNetworkService<IBLAPITarget>.shared.request(.portalAuth(account, password, auth))

        
        return self.handlerError(response: result)
    }

    public func request<T>(_ token: IBLAPITarget) -> Driver<Result<T, MoyaError>> {
        let baseURL = "http://\(self.school.serverInner!)"
        
        return reachable(url: baseURL).flatMapLatest {
            if ($0) {
                IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
            }else {
                IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
                
            }
            
            let result: Single<PFSResponseObject<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
            
            return self.handlerError(response: result)
        }
    }

    public func request<T: Mappable>(_ token: IBLAPITarget) -> Driver<Result<[T], MoyaError>> {
        let baseURL = "http://\(self.school.serverInner!)"

        return reachable(url: baseURL).flatMapLatest {
            if ($0) {
                IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
            }else {
                IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
                
            }
            
            let result: Single<PFSResponseMappableArray<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
            
            return self.handlerError(response: result)
        }
    }


    public func request<T>(_ token: IBLAPITarget) -> Driver<Result<[T], MoyaError>> {
        let baseURL = "http://\(self.school.serverInner!)"

        return reachable(url: baseURL).flatMapLatest {
            if ($0) {
                IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
            }else {
                IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
                
            }
            
            let result: Single<PFSResponseArray<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
            
            return self.handlerError(response: result)
        }

//        let networkReachabilityManager = NetworkReachabilityManager()!
//        
//        let result: Observable<PFSResponseArray<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
//        
//        if !networkReachabilityManager.isReachable {
//            return Driver.just(Result<[T], MoyaError>(error: error(message: "无网络链接")))
//        }else if networkReachabilityManager.isReachableOnEthernetOrWiFi {
//            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
//            
//            return self.handlerError(response: result).flatMapLatest{  result -> Driver<Result<[T], MoyaError>> in
//                do {
//                    let _ = try result.dematerialize()
//                } catch  {
//                    switch error {
//                    case MoyaError.underlying:
//                        guard let cerror = error as? NSError,cerror.domain == NSURLErrorDomain, cerror.code == -1004  else {
//                            return Driver.just(result)
//                        }
//                        
//                        IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
//                        let result: Observable<PFSResponseArray<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
//                        
//                        return self.handlerError(response: result)
//                    default:
//                        return Driver.just(result)
//                    }
//                }
//                return Driver.just(result)
//            }
//            
//        }else {
//            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
//            return self.handlerError(response: result)
//        }
    }
    
    public func request<T: Mappable>(_ token: IBLAPITarget) -> Driver<Result<T, MoyaError>> {
        
        let baseURL = "http://\(self.school.serverInner!)"
        
        return reachable(url: baseURL).flatMapLatest {
            if ($0) {
                IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
            }else {
                IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")

            }
            
            let result: Single<PFSResponseMappableObject<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)

            return self.handlerError(response: result)
        }
    }

    public func request(_ token: IBLAPITarget) -> Driver<Result<String, MoyaError>> {
        let baseURL = "http://\(self.school.serverInner!)"
        
        return reachable(url: baseURL).flatMapLatest {
            if ($0) {
                IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
            }else {
                IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
                
            }
            
            let result: Single<PFSResponseNil> = PFSNetworkService<IBLAPITarget>.shared.request(token)
            
            return self.handlerError(response: result)
        }
    }

    func user(account: String) -> Driver<Result<IBLUser, MoyaError>> {
        return Driver.just(Result{
            guard let user: IBLUser = PFSRealm.shared.object("account == '\(account)'") else {
                throw error(message: "无登陆用户！")
            }

            return user
        })
    }
}
