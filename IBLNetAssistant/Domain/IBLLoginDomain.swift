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

    func auth(account: String, password: String) -> Driver<Result<IBLUser?, MoyaError>> {
        let result = IBLDataRepository.shared.auth(account: account, password: password)
        
        return self.toDriver(ob: result)
    }

    func register(account: String, school: IBLSchool) -> Driver<Result<String, MoyaError>> {

        var result :Observable<Result<String, MoyaError>> = Observable.just(Result(value: ""))

        if let _: Bool = IBLDataRepository.shared.fetch(key: "register") {
            result = IBLDataRepository.shared.register(account: account, school: school).do(onNext: { result in
                guard (try? result.dematerialize()) != nil else {
                    return
                }
                
                IBLDataRepository.shared.save(key: "register", value: true)
             })
        }

        return self.toDriver(ob: result)
    }

    func user(account: String?) -> Driver<Result<IBLUser?, MoyaError>> {

        guard let account = account else {
            return Driver.just(Result<IBLUser?, MoyaError>(error: error(message: "登陆账户为空！")))
        }

        let user: Observable<Result<IBLUser?, MoyaError>> = IBLDataRepository.shared.user(account: account)

        return self.toDriver(ob: user)
    }

    func auth(portal: String) -> Driver<Result<PortalAuth, MoyaError>> {


        return nil
    }

}
