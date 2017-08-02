//
//  IBLSchoolViewModel.swift
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

protocol IBLSchoolAction: PFSViewAction {
    
}

class IBLSchoolSelection: PFSPickerViewItem {
    lazy var title: String = self.school.sname!

    var school: IBLSchool
    
    
    init(school: IBLSchool) {
        self.school = school
    }
}

class IBLSchoolViewModel<T: IBLSchoolAction>: PFSViewModel<T, IBLSchoolDomain> {
    
    var selectedSchool: IBLSchool? = nil
    
    var locationManager = PFSLocationManager()
    
    func setSelectedSchool(school: IBLSchool?) {
        self.selectedSchool = school
    }

    func fetchSchools() -> Driver<[IBLSchoolSelection]> {
        return self.locationManager.startUpdatingLocation().flatMapLatest {
            self.domain.fetchSchools(locationCoordinate2D: $0.coordinate)
        }.flatMapLatest {
            return (self.action?.alert(result: $0))!
        }.map {
                
                var result = [IBLSchoolSelection]()
                switch $0 {
                case .failure(_): break;
                case let .success(schools):
                    result = schools.map{IBLSchoolSelection(school: $0)}
                }
                return result
        }
    }
    
    func cacheSchool() -> Driver<Bool> {
        
        let cacheSelectedSchool = self.domain.cache(school: self.selectedSchool!)
        
        return cacheSelectedSchool.flatMapLatest { [weak self] result in
            return (self?.action?.alert(result: result))!
        }.flatMapLatest {
            guard let _ = try? $0.dematerialize() else {
                return Driver.just(false)
            }

            return Driver.just(true)
        }
    }


}
