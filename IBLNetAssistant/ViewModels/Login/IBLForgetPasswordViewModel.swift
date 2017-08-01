//
//  IBLLoginViewModel.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 05/06/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import PCCWFoundationSwift
import RxCocoa
import RxSwift
import Result
import Moya
import class Alamofire.NetworkReachabilityManager

protocol IBLForgetPasswordAction: PFSViewAction {

}

class IBLForgetPasswordViewModel: PFSViewModel<IBLForgetPasswordViewController, IBLForgetPasswordDomain> {

    var account: Variable<String>

    var phone: Variable<String>

    init(action: IBLForgetPasswordViewController, domain: IBLForgetPasswordDomain, account: String) {
        self.account = Variable(account)
        self.phone = Variable("")
        super.init(action: action, domain: domain)
    }

    func sendSMS() -> Driver<Bool> {

        let validateAccount = account.value.notNul(message: "用户名不能为空！")

        let validatePhone = phone.value.notNul(message: "密码不能为空！")

        let validateResult = PFSValidate.of(validateAccount, validatePhone)


        let sms: Driver<Result<String, MoyaError>> = self.domain.sendSMS(account: account.value, phone: phone.value)

        return validateResult.flatMapLatest {
            return (self.action?.alert(result: $0))!
        }.flatMapLatest {_ in 
            return sms
        }.flatMapLatest {
            return self.action!.alert(result: $0)
        }.flatMapLatest { _ in
            return Driver.just(true)
        }
    }
}
