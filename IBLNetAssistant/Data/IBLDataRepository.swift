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

class IBLDataRepository: PFSDataRepository {

    static let shared = IBLDataRepository()


    override init() {
        super.init()
    }

    func fetchSchools() -> Observable<Result<[IBLSchool], MoyaError>> {
        let result: Observable<PFSResponseMappableArray<IBLSchool>> = PFSNetworkService<IBLAPITarget>.shared.request(.school("116.317489", "39.998813"))

        return self.handlerError(response: result)
    }

    func auth(account: String, password: String) -> Observable<Result<IBLUser?, MoyaError>> {

        let result: Observable<PFSResponseMappableObject<IBLUser>> = PFSNetworkService<IBLAPITarget>.shared.request(.auth(account, password))
                
        return self.handlerError(response: result)

    }

    func register(account: String, school: IBLSchool) -> Observable<Result<String, MoyaError>> {

        let result: Observable<PFSResponseNil> = PFSNetworkService<IBLAPITarget>.shared.request(.register(account,school))
        
        return self.handlerError(response: result)
    }

    func cachedSchool() -> Observable<Result<IBLSchool, MoyaError>> {
        return Observable.just(Result{
            guard let cachedSchool: IBLSchool = PFSRealm.shared.object() else {
                throw error(message: "无缓存学校！")
            }

            return cachedSchool
        })
    }

    func cachedUser() -> Observable<Result<IBLUser?, MoyaError>> {
        return Observable.just(Result{
            guard let cachedUser: IBLUser = PFSRealm.shared.object() else {
                throw error(message: "无登陆用户！")
            }

            return cachedUser
        })
    }

}
