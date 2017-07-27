//
//  IBLWebDomain.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 26/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift
import Result
import Moya
import RxCocoa
import RxSwift

class IBLWebDomain: PFSDomain {

    func logout(account: String, auth: PortalAuth) -> Driver<Result<String, MoyaError>> {
        return IBLDataRepository.shared.logout(account, auth: auth).do(onNext: {
            guard (try? $0.dematerialize()) != nil else {
                return
            }
            self.login()?.isLogin = true
        })
    }
}
