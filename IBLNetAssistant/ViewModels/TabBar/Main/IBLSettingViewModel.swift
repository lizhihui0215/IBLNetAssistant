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
import RxRealm
import Result
import Moya

protocol IBLSettingAction: PFSViewAction {
    
}
class IBLSettingViewModel: PFSViewModel<IBLSettingViewController, IBLSettingDomain> {
    var isAutoLogin: Variable<Bool>
    
    var user: IBLUser?
    
    var selectedSchool: IBLSchool
    
    var locationManager = PFSLocationManager()
    
    var schoolName: Variable<String>
    
    override init(action: IBLSettingViewController, domain: IBLSettingDomain) {
        self.user = PFSDomain.login()
        self.isAutoLogin = Variable(self.user?.isAutoLogin ?? false)
        self.selectedSchool = PFSDomain.cachedSchool()!
        self.schoolName = Variable(self.selectedSchool.sname!)
        super.init(action: action, domain: domain)
        
        if let user = self.user {
            self.isAutoLogin.asObservable().subscribe(onNext: { isAutoLigin in
                PFSRealm.shared.update(obj: user, {
                    $0.isAutoLogin = isAutoLigin
                })
            }).disposed(by: disposeBag)
        }
    }
    
    func isEnableLoginSwitch() -> Bool {
        return self.user != nil
    }
    
    func setSelectedSchool(school: IBLSchool) -> Driver<IBLSchool?> {
        return ((self.action?.confirm(message:"切换校园之后，您的数据将丢失，请谨慎操作，确认切换吗？", content: school))?.do(onNext: { school in
            self.domain.switchSchool(school: school!)
        }))!
    }
    
    func fetchSchools() -> Driver<[IBLSchoolSelection]> {
        return self.locationManager.startUpdatingLocation().flatMapLatest {
            self.domain.fetchSchools(locationCoordinate2D: $0.coordinate)
            }.flatMapLatest {
                return (self.action?.toast(result: $0))!
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
}
