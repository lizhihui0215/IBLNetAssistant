//
//  IBLLoginDomain.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 12/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift
import RxSwift
import RxCocoa
import Moya
import Result

class IBLLoginDomain: PFSDomain {

    override init() {
        super.init()
    
    }

    func auth(account: String, password: String) -> Driver<Result<IBLUser, MoyaError>> {
        let result = IBLDataRepository.shared.auth(account: account, password: password).do(onNext: {
            let user = try? $0.dematerialize()
            user?.loginModel = "0"
        })

        return result
    }

    func register(account: String, school: IBLSchool) -> Driver<Result<String, MoyaError>> {

        var result :Driver<Result<String, MoyaError>> = Driver.just(Result(value: ""))

        if let _: Bool = IBLDataRepository.shared.cache(key: "register") {
            result = IBLDataRepository.shared.register(account: account, school: school).do(onNext: { result in
                guard (try? result.dematerialize()) != nil else {
                    return
                }
                
                IBLDataRepository.shared.cache(key: "register", value: true)
             })
        }

        return result
    }

    func user(account: String?) -> Driver<Result<IBLUser, MoyaError>> {

        guard let account = account else {
            return Driver.just(Result<IBLUser, MoyaError>(error: error(message: "登陆账户为空！")))
        }

        let user: Driver<Result<IBLUser, MoyaError>> = IBLDataRepository.shared.user(account: account)

        return user
    }

    func portal(url: String) -> Driver<Result<PortalAuth, MoyaError>> {

        let auth: Driver<Result<PortalAuth, MoyaError>> = IBLDataRepository.shared.portal(url: url)

        return auth
    }

    func portalAuth(account: String, password: String, auth: [String: Any]) -> Driver<Result<IBLUser, MoyaError>> {
        let result: Driver<Result<IBLUser, MoyaError>> = IBLDataRepository.shared.portalAuth(account: account, password: password, auth).do(onNext: {
            let user = try? $0.dematerialize()
            user?.loginModel = "1"
        })

        return result
    }

}
