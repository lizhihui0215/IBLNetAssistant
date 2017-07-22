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
import ObjectMapper
import class Alamofire.NetworkReachabilityManager

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

    func fetchSchools() -> Observable<Result<[IBLSchool], MoyaError>> {
        let result: Observable<PFSResponseMappableArray<IBLSchool>> = PFSNetworkService<IBLAPITarget>.shared.request(.school("116.317489", "39.998813"))

        return self.handlerError(response: result)
    }

    func auth(account: String, password: String) -> Observable<Result<IBLUser?, MoyaError>> {
        return self.request(.auth(account, password))
    }

    func register(account: String, school: IBLSchool) -> Observable<Result<String, MoyaError>> {
        return self.request(.register(account,school))
    }

    func cachedSchool() -> Observable<Result<IBLSchool, MoyaError>> {
        return Observable.just(Result{
            guard let cachedSchool: IBLSchool = PFSRealm.shared.object() else {
                throw error(message: "无缓存学校！")
            }

            return cachedSchool
        })
    }

    public func request<T>(_ token: IBLAPITarget) -> Observable<Result<T?, MoyaError>> {
        let networkReachabilityManager = NetworkReachabilityManager()!
        
        let result: Observable<PFSResponseObject<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
        
        if !networkReachabilityManager.isReachable {
            return Observable.just(Result<T?, MoyaError>(error: error(message: "无网络链接")))
        }else if networkReachabilityManager.isReachableOnEthernetOrWiFi {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
            
            return self.handlerError(response: result).flatMapLatest{  result -> Observable<Result<T?, MoyaError>> in
                guard (try? result.dematerialize()) != nil else {
                    IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
                    let result: Observable<PFSResponseObject<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
                    
                    return self.handlerError(response: result)
                }
                return Observable.just(result)
            }

        }else {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
            return self.handlerError(response: result)
        }
    }

    public func request<T: Mappable>(_ token: IBLAPITarget) -> Observable<Result<[T], MoyaError>> {
        let networkReachabilityManager = NetworkReachabilityManager()!
        
        let result: Observable<PFSResponseMappableArray<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
        
        if !networkReachabilityManager.isReachable {
            return Observable.just(Result<[T], MoyaError>(error: error(message: "无网络链接")))
        }else if networkReachabilityManager.isReachableOnEthernetOrWiFi {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
            
            return self.handlerError(response: result).flatMapLatest{  result -> Observable<Result<[T], MoyaError>> in
                guard (try? result.dematerialize()) != nil else {
                    IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
                    let result: Observable<PFSResponseMappableArray<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
                    
                    return self.handlerError(response: result)
                }
                return Observable.just(result)
            }
            
        }else {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
            return self.handlerError(response: result)
        }
    }


    public func request<T>(_ token: IBLAPITarget) -> Observable<Result<[T], MoyaError>> {
        let networkReachabilityManager = NetworkReachabilityManager()!
        
        let result: Observable<PFSResponseArray<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
        
        if !networkReachabilityManager.isReachable {
            return Observable.just(Result<[T], MoyaError>(error: error(message: "无网络链接")))
        }else if networkReachabilityManager.isReachableOnEthernetOrWiFi {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
            
            return self.handlerError(response: result).flatMapLatest{  result -> Observable<Result<[T], MoyaError>> in
                guard (try? result.dematerialize()) != nil else {
                    IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
                    let result: Observable<PFSResponseArray<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
                    
                    return self.handlerError(response: result)
                }
                return Observable.just(result)
            }
            
        }else {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
            return self.handlerError(response: result)
        }
    }

    public func request<T: Mappable>(_ token: IBLAPITarget) -> Observable<Result<T?, MoyaError>> {
        let networkReachabilityManager = NetworkReachabilityManager()!
        
        let result: Observable<PFSResponseMappableObject<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
        
        if !networkReachabilityManager.isReachable {
            return Observable.just(Result<T?, MoyaError>(error: error(message: "无网络链接")))
        }else if networkReachabilityManager.isReachableOnEthernetOrWiFi {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
            
            return self.handlerError(response: result).flatMapLatest{  result -> Observable<Result<T?, MoyaError>> in
                guard (try? result.dematerialize()) != nil else {
                    IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
                    let result: Observable<PFSResponseMappableObject<T>> = PFSNetworkService<IBLAPITarget>.shared.request(token)
                    
                    return self.handlerError(response: result)
                }
                return Observable.just(result)
            }
            
        }else {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
            return self.handlerError(response: result)
        }
    }

    public func request(_ token: IBLAPITarget) -> Observable<Result<String, MoyaError>> {
        let networkReachabilityManager = NetworkReachabilityManager()!
        
        let result: Observable<PFSResponseNil> = PFSNetworkService<IBLAPITarget>.shared.request(token)
        
        if !networkReachabilityManager.isReachable {
            return Observable.just(Result<String, MoyaError>(error: error(message: "无网络链接")))
        }else if networkReachabilityManager.isReachableOnEthernetOrWiFi {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")
            
            return self.handlerError(response: result).flatMapLatest{  result -> Observable<Result<String, MoyaError>> in
                guard (try? result.dematerialize()) != nil else {
                    IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
                    let result: Observable<PFSResponseNil> = PFSNetworkService<IBLAPITarget>.shared.request(token)
                    
                    return self.handlerError(response: result)
                }
                return Observable.just(result)
            }
        }else {
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
            return self.handlerError(response: result)
        }
    }

    func user(account: String) -> Observable<Result<IBLUser?, MoyaError>> {
        return Observable.just(Result{
            guard let user: IBLUser = PFSRealm.shared.object("account == '\(account)'") else {
                throw error(message: "无登陆用户！")
            }

            return user
        })
    }
}
