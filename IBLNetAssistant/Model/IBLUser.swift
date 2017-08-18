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

public class IBLUser: PFSModel {
    dynamic var accessToken : String?
    
    dynamic var isAutoLogin: Bool = false
    
    dynamic var account: String = ""
    
    dynamic var password: String = ""
    
    dynamic var selectedSchool: IBLSchool?
    
    dynamic var auth: PortalAuth?
    
    dynamic var isLogin: Bool = false

    dynamic var redirectUrl = ""
    
    dynamic var loginModel = ""
    
    var onlineList: [IBLOnline]?
    
    
    required convenience public init?(map: Map) {
        self.init()
    }
    
    override public static func ignoredProperties() -> [String] {
        return ["onlineList"]
    }
    
    override public func mapping(map: Map) {
        super.mapping(map: map)
        accessToken <- map["accessToken"]
        account <- map["account"]
        password <- map["password"]
        isAutoLogin <- map["isAutoLogin"]
        selectedSchool <- map["selectedSchool"]
        isLogin <- map["isLogin"]
        redirectUrl <- map["redirectUrl"]
        auth <- map["auth"]
        loginModel <- map["loginModel"]
        onlineList <- map["onlineList"]
    }

    

}
