//
//  IBLSettingDomain.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 27/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import Foundation
import PCCWFoundationSwift
import RxCocoa
import RxSwift
import Result
import Moya
import RealmSwift

class IBLSettingDomain: PFSDomain {
    func fetchSchools(locationCoordinate2D: CLLocationCoordinate2D) -> Driver<Result<[IBLSchool], Moya.MoyaError>> {
        let result: Driver<Result<[IBLSchool], Moya.MoyaError>> = IBLDataRepository.shared.fetchSchools(locationCoordinate2D: locationCoordinate2D)
        
        return result
    }
    
    func switchSchool(school: IBLSchool)  {
        PFSDomain.login(user: nil)
        try? PFSRealm.shared.clean()
        PFSRealm.shared.save(obj: school)
        IBLDataRepository.shared.school = IBLSchool()
    }
}
