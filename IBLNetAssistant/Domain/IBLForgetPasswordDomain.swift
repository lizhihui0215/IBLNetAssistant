//
//  IBLForgetPasswordDomain.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 31/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import PCCWFoundationSwift
import RxCocoa
import RxSwift
import Result
import Moya
import RealmSwift

class IBLForgetPasswordDomain: PFSDomain {

    func sendSMS(account: String, phone: String) -> Driver<Result<String, MoyaError>> {
        return IBLDataRepository.shared.sendSMS(account: account, phone: phone)
    }
}
