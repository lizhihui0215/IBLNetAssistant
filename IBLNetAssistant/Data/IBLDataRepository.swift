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
    
    private var _school: IBLSchool = IBLSchool()

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
    }

    override init() {
        super.init()
    }

    func fetchSchools() -> Driver<Result<[IBLSchool], MoyaError>> {
        let result: Observable<PFSResponseMappableArray<IBLSchool>> = PFSNetworkService<IBLAPITarget>.shared.request(.school("116.317489", "39.998813"))

        return self.handlerError(response: result)
    }

    func auth(account: String, password: String) -> Driver<Result<IBLUser, MoyaError>> {
        return self.request(.auth(account, password))
    }

    func register(account: String, school: IBLSchool) -> Driver<Result<String, MoyaError>> {
        return self.request(.register(account,school))
    }
    
    func portal(url: String) -> Driver<Result<PortalAuth, MoyaError>> {
        let result: Observable<PFSResponseMappableObject<PortalAuth>> = PFSNetworkService<IBLAPITarget>.shared.request(.portal(url))

        return self.handlerError(response: result)
    }

    func logout(_ account: String, auth: PortalAuth) -> Driver<Result<String, MoyaError>> {
        let result: Observable<PFSResponseNil> = PFSNetworkService<IBLAPITarget>.shared.request(.logout(account,auth.toJSONRealm()!))

        return self.handlerError(response: result)
    }

    func cachedSchool() -> Driver<Result<IBLSchool, MoyaError>> {
        return Driver.just(Result{
            guard let cachedSchool: IBLSchool = PFSRealm.shared.object() else {
                throw error(message: "无缓存学校！")
            }

            return cachedSchool
        })
    }

    func portalAuth(account: String, password: String, _ auth: [String: Any]) -> Driver<Result<IBLUser, MoyaError>> {
        return self.request(.portalAuth(account, password, auth))
    }

    public func request<T>(_ token: IBLAPITarget) -> Driver<Result<T, MoyaError>> {
        let networkReachabilityManager = NetworkReachabilityManager()!
        
        let result: Observable<PFSResponseObject<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
        
        if !networkReachabilityManager.isReachable {
            return Driver.just(Result<T, MoyaError>(error: error(message: "无网络链接")))
        }else if networkReachabilityManager.isReachableOnEthernetOrWiFi {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
            
            return self.handlerError(response: result).flatMapLatest{  result -> Driver<Result<T, MoyaError>> in
                guard (try? result.dematerialize()) != nil else {
                    IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
                    let result: Observable<PFSResponseObject<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
                    
                    return self.handlerError(response: result)
                }
                return Driver.just(result)
            }

        }else {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
            return self.handlerError(response: result)
        }
    }

    public func request<T: Mappable>(_ token: IBLAPITarget) -> Driver<Result<[T], MoyaError>> {
        let networkReachabilityManager = NetworkReachabilityManager()!
        
        let result: Observable<PFSResponseMappableArray<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
        
        if !networkReachabilityManager.isReachable {
            return Driver.just(Result<[T], MoyaError>(error: error(message: "无网络链接")))
        }else if networkReachabilityManager.isReachableOnEthernetOrWiFi {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
            
            return self.handlerError(response: result).flatMapLatest{  result -> Driver<Result<[T], MoyaError>> in
                guard (try? result.dematerialize()) != nil else {
                    IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
                    let result: Observable<PFSResponseMappableArray<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
                    
                    return self.handlerError(response: result)
                }
                return Driver.just(result)
            }
            
        }else {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
            return self.handlerError(response: result)
        }
    }


    public func request<T>(_ token: IBLAPITarget) -> Driver<Result<[T], MoyaError>> {
        let networkReachabilityManager = NetworkReachabilityManager()!
        
        let result: Observable<PFSResponseArray<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
        
        if !networkReachabilityManager.isReachable {
            return Driver.just(Result<[T], MoyaError>(error: error(message: "无网络链接")))
        }else if networkReachabilityManager.isReachableOnEthernetOrWiFi {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
            
            return self.handlerError(response: result).flatMapLatest{  result -> Driver<Result<[T], MoyaError>> in
                guard (try? result.dematerialize()) != nil else {
                    IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
                    let result: Observable<PFSResponseArray<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
                    
                    return self.handlerError(response: result)
                }
                return Driver.just(result)
            }
            
        }else {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
            return self.handlerError(response: result)
        }
    }

    public func request<T: Mappable>(_ token: IBLAPITarget) -> Driver<Result<T, MoyaError>> {
        let networkReachabilityManager = NetworkReachabilityManager()!
        
        let result: Observable<PFSResponseMappableObject<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
        
        if !networkReachabilityManager.isReachable {
            return Driver.just(Result<T, MoyaError>(error: error(message: "无网络链接")))
        }else if networkReachabilityManager.isReachableOnEthernetOrWiFi {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
            
            return self.handlerError(response: result).flatMapLatest{  result -> Driver<Result<T, MoyaError>> in
                guard (try? result.dematerialize()) != nil else {
                    IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
                    let result: Observable<PFSResponseMappableObject<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
                    
                    return self.handlerError(response: result)
                }
                return Driver.just(result)
            }
            
        }else {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
            return self.handlerError(response: result)
        }
    }

    public func request(_ token: IBLAPITarget) -> Driver<Result<String, MoyaError>> {
        let networkReachabilityManager = NetworkReachabilityManager()!
        
        let result: Observable<PFSResponseNil> = PFSNetworkService<IBLAPITarget>.shared.request(token)
        
        if !networkReachabilityManager.isReachable {
            return Driver.just(Result<String, MoyaError>(error: error(message: "无网络链接")))
        }else if networkReachabilityManager.isReachableOnEthernetOrWiFi {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
            
            return self.handlerError(response: result).flatMapLatest{  result -> Driver<Result<String, MoyaError>> in
                guard (try? result.dematerialize()) != nil else {
                    IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
                    let result: Observable<PFSResponseNil> = PFSNetworkService<IBLAPITarget>.shared.request(token)
                    
                    return self.handlerError(response: result)
                }
                return Driver.just(result)
            }
        }else {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
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
