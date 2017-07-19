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

protocol IBLLoginAction: PFSViewAction {
    
}

class IBLLoginViewModel: PFSViewModel<IBLLoginViewController, IBLLoginDomain>  {

    var school: IBLSchool

    var account: Variable<String?>

    var isAutoLogin = Variable(false)
    

    init(action: IBLLoginViewController, domain: IBLLoginDomain, school: IBLSchool) {
        self.school = school
        self.account = Variable("")
        super.init(action: action, domain: domain)
    }

    func sigin(account: String, password: String) -> Driver<Bool> {

        let isProtalSigin = self.school.mode != "0"
        
        let validateAccount = account.notNul(message: "用户名不能为空！")
        
        let validatePassword = password.notNul(message: "密码不能为空！")
        
        let validateResult = PFSValidate.of(validateAccount, validatePassword)

        var sigin: Driver<Bool> = Driver.just(true)
        
        let networkReachabilityManager = NetworkReachabilityManager()!
        
        if !networkReachabilityManager.isReachable {
            return (self.action?.alert(message: "无网络链接！",success: false))!
        }else if networkReachabilityManager.isReachableOnEthernetOrWiFi && isProtalSigin {
            sigin = self.portalSigin(account: account, password: password)
        }else {
            sigin = self.selfSigin(account: account, password: password)
        }

        return  validateResult.flatMapLatest{
                        return (self.action?.alert(result: $0))!
                    }.flatMapLatest { _ in
                        return sigin
                    }
    }
    
    private func portalSigin(account: String, password: String) -> Driver<Bool>  {
        IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverInner!)")

        
        return Driver.just(true)
    }

    private func selfSigin(account: String, password: String) -> Driver<Bool> {
        IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")

        let register: Driver<Result<String, MoyaError>> = self.domain.register(account: account, school: self.school)
        
            return register.flatMapLatest{
                return (self.action?.alert(result: $0))!
            }.flatMapLatest{_ in
                return self.domain.auth(account: account, password: password)
            }.flatMapLatest{
                return (self.action?.alert(result: $0))!
            }.flatMapLatest{
                guard let result =  try? $0.dematerialize(), let accessToken = result?.accessToken else {
                    return Driver.just(false)
                }
                
                guard let cachedUser: IBLUser = PFSRealm.shared.object(account) else {
                    let user: IBLUser = IBLUser()
                    
                    user.isAutoLogin = self.isAutoLogin.value
                    user.account = account
                    user.password = password
                    user.selectedSchool = self.school
                    user.accessToken = accessToken
                    user.isLogin = true
                    
                    guard let _ =  try? PFSRealm.shared.save(obj: user).dematerialize() else {
                        return Driver.just(false)
                    }
                    
                    IBLDataRepository.shared.put(key: "test", value: "ccccccc")
                    
                    var c: String? = IBLDataRepository.shared.get(key: "test")
                    
                    IBLDataRepository.shared.save(key: "qqq", value: "dsadadada")
                    
                    var cc: String? = IBLDataRepository.shared.get(key: "qqq")

                    self.domain.login(user: user)
                    
                    var userccc = self.domain.login()
                    
                    return Driver.just(true)
                }
                
                guard let _ =  try? PFSRealm.shared.update(obj: cachedUser, {
                    $0.isAutoLogin = self.isAutoLogin.value
                    $0.password = password
                    $0.selectedSchool = self.school
                    $0.isLogin = true
                    $0.accessToken = accessToken

                }).dematerialize() else {
                    return Driver.just(false)
                }
                
                return Driver.just(true)
        }
    }

    func cachedUser() -> Driver<Bool> {
        let lastUser: Driver<Result<IBLUser?, MoyaError>> = self.domain.cachedUser();

        return lastUser.flatMapLatest {
            guard let result = try? $0.dematerialize(), let user = result else {
                return Driver.just(false)
            }
            
            self.isAutoLogin.value = user.isAutoLogin
            self.school = user.selectedSchool!
            self.account.value = user.account
            
            if user.selectedSchool!.mode == "0" {
                return Driver.just(user.isAutoLogin)
            }
            
            return Driver.just(user.isAutoLogin)
        }
    }

}
