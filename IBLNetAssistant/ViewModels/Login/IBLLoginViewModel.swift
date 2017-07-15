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

protocol IBLLoginAction: PFSViewAction {
    
}


class IBLLoginViewModel: PFSViewModel<IBLLoginViewController, IBLLoginDomain>  {

    var school: IBLSchool

    init(action: IBLLoginViewController, domain: IBLLoginDomain, school: IBLSchool) {
        self.school = school
        super.init(action: action, domain: domain)
    }

    func sigin(account: String, password: String) -> Driver<Bool> {

        let isSelfService = self.school.mode == "0"
        
        if isSelfService{
            IBLAPITarget.setBaseURL(URL: "http://\(self.school.serverOut!)")
        }

        let register: Driver<Result<String, MoyaError>> = self.domain.register(account: account, school: self.school)
        
        
        var sigin: Driver<Bool> = Driver.just(true)
        
        if isSelfService {
            sigin = register.flatMapLatest{
                return (self.action?.alert(result: $0))!
            }.flatMapLatest{_ in
                return self.siginSelfService(account: account, password: password)
            }.flatMapLatest{
                return (self.action?.alert(result: $0))!
            }.flatMapLatest{_ in
                Driver.just(true)
            }
        }
        
        return sigin
    }

    private func siginSelfService(account: String, password: String) -> Driver<Result<IBLUser?, MoyaError>> {
        
        let t: Driver<Result<IBLUser?, MoyaError>> = self.domain.auth(account: account, password: password)
        return t
    }
}
