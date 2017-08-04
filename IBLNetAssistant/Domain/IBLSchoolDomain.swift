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

    func fetchSchools(locationCoordinate2D: CLLocationCoordinate2D) -> Driver<Result<[IBLSchool], Moya.Error>> {
        let result: Driver<Result<[IBLSchool], Moya.Error>> = IBLDataRepository.shared.fetchSchools(locationCoordinate2D: locationCoordinate2D)
        
        return result
    }

    func cache(school: IBLSchool) -> Driver<Result<IBLSchool, MoyaError>> {
        try? PFSRealm.shared.clean()
        return Driver.just(PFSRealm.shared.save(obj: school))
    }
}
