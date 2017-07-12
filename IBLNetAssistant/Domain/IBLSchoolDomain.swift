//
//  IBLSchoolDomain.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 12/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift
import RxSwift
import RxCocoa
import Result
import Moya


class IBLSchoolDomain: PFSDomain {



    override init() {
        super.init()
    }

    func fetchSchools() -> Driver<Result<[IBLSchool], Moya.Error>> {
        let result: Observable<Result<[IBLSchool], Moya.Error>> = IBLDataRepository.shared.fetchSchools()
        
        return toDriver(ob: result)
    }
}
