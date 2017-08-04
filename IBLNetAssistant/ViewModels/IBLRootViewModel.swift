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
    
    func cachedSchool() -> IBLSchool? {
        self.school = PFSDomain.cachedSchool()
        return self.school
    }
}
