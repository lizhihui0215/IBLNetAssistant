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
    

    func fetchSchools() -> Driver<[IBLSchoolSelection]> {
        let schools: Driver<Result<[IBLSchool], Moya.Error>> = self.domain.fetchSchools().do(onNext: { print("next \($0)")
        }, onCompleted: { 
            print("completed")
        }, onSubscribe: { 
            print("onSubscribe")
        }) { 
            print("onSubscribe")
        }
        
        let c = schools.flatMapLatest {
            return (self.action?.alert(result: $0))!
        }
        
        
        let x: Driver<[IBLSchoolSelection]> = c.map {
            
            var result = [IBLSchoolSelection]()
            switch $0 {
            case .failure(_): break;
            case let .success(schools):
                result = schools.map{IBLSchoolSelection(school: $0)}
            }
            return result
        }
        
        
        
        return x
    }
    

}
