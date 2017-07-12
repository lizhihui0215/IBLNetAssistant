//
//  IBLDataResponsitory.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 12/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift
import RxSwift
import Result
import Moya

class IBLDataRepository: PFSDataRepository {

    static let shared = IBLDataRepository()
    
    
    override init() {
        super.init()
    }

    func fetchSchools() -> Observable<Result<[IBLSchool], Moya.Error>> {
        let result: Observable<PFSResponseMappableArray<IBLSchool>> = PFSNetworkService<IBLAPITarget>.shared.request(.school("116.317489", "39.998813"))
        
        return self.handlerError(response: result)
    }

}
