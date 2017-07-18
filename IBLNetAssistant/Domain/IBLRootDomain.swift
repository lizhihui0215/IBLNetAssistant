//
//  IBLRootDomain.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 16/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift
import RxCocoa
import Result
import Moya
import RxSwift

class IBLRootDomain: PFSDomain {
    override init() {
        
    }

    func cachedSchool() -> Driver<Result<IBLSchool, MoyaError>> {
        let cachedSchool: Observable<Result<IBLSchool, MoyaError>> = IBLDataRepository.shared.cachedSchool()

        return self.toDriver(ob: cachedSchool)
    }
}
