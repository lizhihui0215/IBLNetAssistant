//
//  IBLSchool.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 12/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift
import ObjectMapper_Realm
import PCCWFoundationSwift


class IBLSchool: PFSModel {
    
    dynamic var sid : String?
    dynamic var sname : String?
    dynamic var mode : String?
    dynamic var serverInner : String?
    dynamic var serverOut : String?
    dynamic var selected : String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        sid <- map["sid"]
        sname <- map["sname"]
        mode <- map["mode"]
        serverInner <- map["server_inner"]
        serverOut <- map["server_out"]
        selected <- map["selected"]
    }

}
