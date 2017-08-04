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

class IBLLoginViewModel: PFSViewModel<IBLLoginViewController, IBLLoginDomain> {
    
    var school: IBLSchool
    
    var account: Variable<String?>
    
    var auth: PortalAuth?
    
    var isAutoLogin = Variable(false)
    
    
    init(action: IBLLoginViewController, domain: IBLLoginDomain, school: IBLSchool) {
        self.school = school
        self.account = Variable("")
        super.init(action: action, domain: domain)
    }
    
    func sigin(account: String, password: String) -> Driver<Bool> {
        
        let isProtalSigin = self.school.mode != "0"
        
        let validateAccount = account.notNull(message: "用户名不能为空！")
        
        let validatePassword = password.notNull(message: "密码不能为空！")
        
        let validateResult = PFSValidate.of(validateAccount, validatePassword)
        
        var sigin: Driver<Bool> = Driver.just(true)
        
        let networkReachabilityManager = NetworkReachabilityManager()!
        
        if !networkReachabilityManager.isReachable {
            return (self.action?.alert(message: "无网络链接！", success: false))!
        } else if networkReachabilityManager.isReachableOnEthernetOrWiFi && isProtalSigin {
            sigin = self.portalSigin(account: account, password: password)
        } else {
            sigin = self.selfSigin(account: account, password: password)
        }
        
        return  validateResult.flatMapLatest {
            return (self.action?.alert(result: $0))!
            }.flatMapLatest { _ in
                return sigin
        }
    }
    
    private func portalSigin(account: String, password: String) -> Driver<Bool> {
        return self.domain.register(account: account, school: self.school).flatMapLatest { result in
            (self.action?.alert(result: result))!
            }.flatMapLatest { result -> Driver<Result<PortalAuth, MoyaError>> in
                
                return self.domain.portal(url: "http://115.28.0.62:8080/ibillingportal/ac.do")
                
                //            return self.domain.portal(url: "http://www.baidu.com/")
                
            }.flatMapLatest { result  in
                
                guard let value = try? result.dematerialize() else {
                    return self.domain.auth(account: account, password: password)
                }
                
                value.account = account
                
                if let auth: PortalAuth = PFSRealm.shared.object("account == '\(account)'")  {
                    PFSRealm.shared.update(obj: auth, {
                        $0.account = value.account
                        $0.authurl = value.authurl
                        $0.logouturl = value.logouturl
                    })
                    self.auth = auth
                }else {
                    self.auth = value
                }
                
                let auth = Dictionary<String, Any>.toJSON(JSONObject: value.JSON!)
                
                let portalAuth: Driver<Result<IBLUser, MoyaError>> = self.domain.portalAuth(account: account, password: password, auth: auth ?? [:])
                return portalAuth
            }.flatMapLatest { (c: Result<IBLUser, MoyaError>) in
                guard (try? c.dematerialize()) != nil else {
                    return self.domain.auth(account: account, password: password)
                }
                return Driver.just(c)
            }.flatMapLatest {
                return (self.action?.alert(result: $0))!
            }.flatMapLatest {
                return self.save(account: account, password: password, user: $0)
            }
    }
    
    private func selfSigin(account: String, password: String) -> Driver<Bool> {
        let register: Driver<Result<String, MoyaError>> = self.domain.register(account: account, school: self.school)
        
        return register.flatMapLatest {
            return (self.action?.alert(result: $0))!
            }.flatMapLatest { _ in
                return self.domain.auth(account: account, password: password)
            }.flatMapLatest {
                return (self.action?.alert(result: $0))!
            }.flatMapLatest {
                return self.save(account: account, password: password, user: $0)
        }
    }
    
    func save(account: String, password: String, user: Result<IBLUser, MoyaError>) -> Driver<Bool> {
        guard let result = try? user.dematerialize(), let accessToken = result.accessToken else {
            return Driver.just(false)
        }
        
        self.domain.account(account)
        
        guard let login: IBLUser = PFSRealm.shared.object("account == '\(account)'") else {
            let user: IBLUser = IBLUser()
            
            user.isAutoLogin = self.isAutoLogin.value
            user.account = account
            user.password = password
            user.selectedSchool = self.school
            user.accessToken = accessToken
            user.isLogin = true
            user.loginModel = result.loginModel
            user.auth = self.auth
            
            guard let _ = try? PFSRealm.shared.save(obj: user).dematerialize() else {
                return Driver.just(false)
            }
            
            PFSDomain.login(user: user)
            
            return Driver.just(true)
        }
        
        guard let _ = try? PFSRealm.shared.update(obj: login, {
            $0.isAutoLogin = self.isAutoLogin.value
            $0.password = password
            $0.selectedSchool = self.school
            $0.isLogin = true
            $0.accessToken = accessToken
            $0.loginModel = result.loginModel
            $0.auth = self.auth
            $0.redirectUrl = result.redirectUrl
        }).dematerialize() else {
            return Driver.just(false)
        }
        
        PFSDomain.login(user: login)
        
        return Driver.just(true)
    }
    
    func login() -> Driver<Bool> {
        let user: Driver<Result<IBLUser, MoyaError>> = self.domain.user(account: self.domain.account());
        
        return user.flatMapLatest {
            guard let user = try? $0.dematerialize() else {
                return Driver.just(false)
            }
            
            self.isAutoLogin.value = user.isAutoLogin
            self.school = user.selectedSchool!
            self.account.value = user.account
            
            PFSDomain.login(user: user)
            
            if !user.isLogin {
                return Driver.just(false)
            }
            
            if user.loginModel == "0" {
                return Driver.just(user.isAutoLogin)
            }
            
            return self.portalSigin(account: user.account, password: user.password)
        }
    }
}
