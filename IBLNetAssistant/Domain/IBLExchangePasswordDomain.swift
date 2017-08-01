//
//  IBLExchangePasswordDomain.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 01/08/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import PCCWFoundationSwift
import RxCocoa
import RxSwift
import Result
import Moya
import RealmSwift

class IBLExchangePasswordDomain: PFSDomain {

    func sendSMS(account: String, phone: String) -> Driver<Result<String, MoyaError>> {
        return IBLDataRepository.shared.sendSMS(account: account, phone: phone)
    }

    func exchangePassword(account: String, phone: String, sms: String, password: String) -> Driver<Result<String, MoyaError>> {
        return IBLDataRepository.shared.exchangePassword(account: account, phone: phone, sms: sms, password: password)
    }
}
