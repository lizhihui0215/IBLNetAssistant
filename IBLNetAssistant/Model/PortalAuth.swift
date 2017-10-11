//
// Created by 李智慧 on 22/07/2017.
// Copyright (c) 2017 李智慧. All rights reserved.
//

import Foundation
import PCCWFoundationSwift
import ObjectMapper

extension Dictionary {
    
    /// Converts an Object to a JSON string with option of pretty formatting
    public func toJSONString(prettyPrint: Bool) -> String? {
        let options: JSONSerialization.WritingOptions = prettyPrint ? .prettyPrinted : []
        if let JSON = self.toJSONData(options: options) {
            return String(data: JSON, encoding: String.Encoding.utf8)
        }
        
        return nil
    }
    
    /// Converts an Object to JSON data with options
    public  func toJSONData( options: JSONSerialization.WritingOptions) -> Data? {
        if JSONSerialization.isValidJSONObject(self) {
            let JSONData: Data?
            do {
                JSONData = try JSONSerialization.data(withJSONObject: self, options: options)
            } catch let error {
                print(error)
                JSONData = nil
            }
            
            return JSONData
        }
        
        return nil
    }
    
    public static func toJSON(JSONObject: String, options: JSONSerialization.ReadingOptions = []) -> Dictionary? {

        guard let JSONData = JSONObject.data(using: .utf8) else {
            return [:]
        }
        
        let JSONDictionary: Dictionary?
        do {
            JSONDictionary = try JSONSerialization.jsonObject(with: JSONData, options: options) as? Dictionary
        } catch let error {
            print(error)
            JSONDictionary = nil
        }
        
        return JSONDictionary
    }
    
}

class PortalAuth: PFSModel {
    @objc dynamic var authurl : String?
    @objc dynamic var logouturl : String?
    @objc dynamic var account: String?
    @objc dynamic var JSON: String?

    required convenience init?(map: Map) {
        self.init()
        let dic = map.JSON
        self.JSON = dic.toJSONString(prettyPrint: true)
    }
 
    override func mapping(map: Map) {
        super.mapping(map: map)
        authurl <- map["authurl"]
        logouturl <- map["logouturl"]
        account <- map["account"]
    }
}
