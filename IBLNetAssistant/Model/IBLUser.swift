//
//  IBLUser.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 15/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift
import ObjectMapper_Realm
import PCCWFoundationSwift

class IBLUser: PFSModel {
    dynamic var accessToken : String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        accessToken <- map["accessToken"]

    }
}
