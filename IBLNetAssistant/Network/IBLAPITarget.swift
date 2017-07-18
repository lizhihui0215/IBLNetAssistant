//
//  IBLAPIClient.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 05/06/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import PCCWFoundationSwift
import Moya
import CryptoSwift

private var APIBaseURL = ""

enum IBLAPITarget: PFSTargetType {


    case school(String, String)
    case auth(String, String)
    case register(String, IBLSchool)
    
    public static func setBaseURL(URL: String) {
        APIBaseURL = URL
    }
    
    func sign(parameters: [String: Any]) -> [String: Any] {
        var parameters = parameters;
        
        let pointer = UnsafeMutablePointer<time_t>.allocate(capacity: MemoryLayout<time_t>.size)
        
        parameters["sessionId"] = time(pointer)
        
        parameters["mCode"] = device.uuid
        
        parameters["authId"] = "a7a19b705ce5c483"
        
        parameters["phoneModel"] = "0"
        
        parameters["osVersion"] = device.appVersion
        
        var formattedParamters = [String]();
        
        for (key, value) in parameters {
            let formatted = "\(key)=\(value)&"
            
            formattedParamters.append(formatted)
        }
        
        formattedParamters.sort{ $0.caseInsensitiveCompare($1) == .orderedAscending}
        
        var result = formattedParamters.joined(separator: "")
        
        result = "\(result)key=c3c2ba77b7bb1c811998f818c578061f"
        
        let sign = result.md5().uppercased()
        
        parameters["sign"] = sign
        
        
        return parameters
    }
    
    var headers: [String : String] {
        return ["user-agent" : "IBILLING_IOS_NETHELPER_APP"]
    }

    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var parameters: [String: Any]? {
        
        var parameters = [String: Any]()
        switch self {
        case let .school(longit,lati):
            parameters = ["longit" : longit, "lati" : lati]
            parameters = sign(parameters: parameters)
        case let .auth(username, password):
            parameters = ["account" : username, "password" : password]
            parameters = sign(parameters: parameters)
        case let .register(account,school):
            parameters = ["account" : account, "sid" : school.sid , "sname" : school.sname ?? ""]
            parameters = sign(parameters: parameters)
        default:break
        }
        
        return parameters
    }
    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var task: Task {
        return .request
    }
    
    var validate: Bool {
        return false
    }
    
    var path: String {
        var path = ""
        switch self {
        case .school(_,_):
            path = "userservice/getschoollist.do"
        case .auth(_,_):
            path = "ibillingportal/userservice/auth.do"
        case .register(_,_):
            path = "nodeibilling/httpservices/user/appRegister.do"
        default:break
        }
        
        return path
    }
    
    var baseURL: URL {
        return URL(string: APIBaseURL)!
    }
    
    var method: Moya.Method {
        return .post
    }


}
