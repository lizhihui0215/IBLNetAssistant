//
//  IBLExchangePassword.swift
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
import class Alamofire.NetworkReachabilityManager

protocol IBLExchangePasswordAction: PFSViewAction {
    
}

class IBLExchangePasswordViewModel: PFSViewModel<IBLExchagePasswordViewController, IBLExchangePasswordDomain> {
    
    var account: Variable<String>
    
    var phone: Variable<String>
    
    var smsCode: Variable<String>
    
    var password: Variable<String>
    
    var confirm: Variable<String>
    
    init(action: IBLExchagePasswordViewController,
         domain: IBLExchangePasswordDomain,
         account: String,
         phone: String) {
        self.account = Variable(account)
        self.phone = Variable(phone)
        self.smsCode = Variable("")
        self.password = Variable("")
        self.confirm = Variable("")
        super.init(action: action, domain: domain)
    }

    
    func sendSMS() -> Driver<Bool> {
        
        let sms: Driver<Result<String, MoyaError>> = self.domain.sendSMS(account: account.value, phone: phone.value)
        
        return sms.flatMapLatest {
                return self.action!.toast(result: $0)
            }.flatMapLatest { _ in
                return Driver.just(true)
        }
    }

    func exchangePassword() -> Driver<Bool> {
        let validateAccount = smsCode.value.notNull(message: "验证码不能为空！")
        
        let validatePassword = password.value.notNull(message: "密码不能为空！")
        
        let validateSame = password.value.same(message: "确认密码不相同！", password.value)
        
        let validateResult = PFSValidate.of(validateAccount, validatePassword, validateSame)
        
        return validateResult.flatMapLatest{
            (self.action?.toast(result: $0))!
        }.flatMapLatest {_ in
            return self.domain.exchangePassword(account: self.account.value, phone: self.phone.value, sms: self.smsCode.value, password: self.password.value)
        }.flatMapLatest {
                (self.action?.toast(result: $0))!
        }.flatMapLatest { _ in
            return Driver.just(true)
        }
    }
}
