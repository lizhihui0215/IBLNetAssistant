//
//  IBLOnline.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 16/08/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import Foundation
import PCCWFoundationSwift
import ObjectMapper

public class IBLOnline: Mappable {
    var account: String?
    var mac: String?
    var userip: String?
    var accesstype: String?
    var clienttype: String?
    var clientname: String?
    var accesstime: String?

    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        account <- map["account"]
        mac <- map["mac"]
        userip <- map["userip"]
        accesstype <- map["accesstype"]
        clienttype <- map["clienttype"]
        clientname <- map["clientname"]
        accesstime <- map["accesstime"]
    }
}
