//
// Created by 李智慧 on 16/07/2017.
// Copyright (c) 2017 李智慧. All rights reserved.
//

import Foundation
import PCCWFoundationSwift
import RxCocoa
import Moya
import Result

protocol IBLRootAction: PFSViewAction {

}

class IBLRootViewModel: PFSViewModel<IBLRootViewController, IBLRootDomain> {

    var school: IBLSchool?
    
    func cachedSchool() -> Driver<Result<IBLSchool, MoyaError>> {
        
        let cachedSchool = self.domain.cachedSchool()
        
        return cachedSchool.do(onNext: {[weak self] school in
            self?.school = try? school.dematerialize()
        })
    }
}
