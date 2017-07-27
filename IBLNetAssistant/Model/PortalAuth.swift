//
// Created by 李智慧 on 22/07/2017.
// Copyright (c) 2017 李智慧. All rights reserved.
//

import Foundation
import PCCWFoundationSwift
import ObjectMapper

class PortalAuth: PFSModel {
    dynamic var acIPKey : String?
    dynamic var userIPKey : String?
    dynamic var authurl : String?
    dynamic var logouturl : String?
    dynamic var account: String?

    required convenience init?(map: Map) {
        self.init()
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        acIPKey <- map["acIPKey"]
        userIPKey <- map["userIPKey"]
        authurl <- map["authurl"]
        logouturl <- map["logouturl"]
        account <- map["account"]
    }
}
