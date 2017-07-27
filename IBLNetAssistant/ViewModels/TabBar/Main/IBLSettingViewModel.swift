//
//  IBLSettingViewModel.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 27/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import PCCWFoundationSwift
import RxSwift
import RxCocoa

protocol IBLSettingAction: PFSViewAction {
    
}
class IBLSettingViewModel: PFSViewModel<IBLSettingViewController, IBLSettingDomain> {
    var isAutoLogin: Variable<Bool>
    
    var user: IBLUser
    
    override init(action: IBLSettingViewController, domain: IBLSettingDomain) {
        self.user = PFSDomain.login()!
        self.isAutoLogin = Variable(self.user.isAutoLogin)
        super.init(action: action, domain: domain)
    }

    
    
}
