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

public func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}

enum IBLAPITarget: PFSTargetType {


    case school(String, String)
    case auth(String, String)
    case register(String, IBLSchool)
    case portal(String)
    case portalAuth(String, String, [String : Any])
    case web([String : Any])
    case logout(String, [String : Any])
    
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
        case let .portalAuth(account, password, auth):
            var param = ["loginName" : account, "loginPwd" : password] as [String : Any]
            param += auth
            parameters = sign(parameters: param)
        case let .web(param):
            parameters = sign(parameters: param)
        case let .logout(account, auth):
            var param = ["loginName" : account] as [String : Any]
            param += auth
            parameters = sign(parameters: param)
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
        case .web(_):
            path = "ibillingportal/userservice/index.do"
        default:break
        }
        
        return path
    }
    
    var baseURL: URL {
        switch self {
        case let .portal(authURL):
            return URL(string: authURL)!
        case let .portalAuth(_,_, auth):
            return URL(string: auth["authurl"] as! String)!
        case let .logout(_, auth):
            return URL(string: auth["logouturl"] as! String)!
        default:
            return URL(string: APIBaseURL)!
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .web(_):
            return .get
        default:
            return .post
        }
    }


}
