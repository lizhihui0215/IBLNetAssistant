//
//  IBLLoginDomain.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 12/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift
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
        let result = IBLDataRepository.shared.register(account: account, school: school)

        return self.toDriver(ob: result)
    }


}
