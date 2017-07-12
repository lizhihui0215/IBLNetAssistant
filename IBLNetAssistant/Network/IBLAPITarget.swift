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

enum IBLAPITarget: PFSTargetType {
    case school(String, String)
    case login
    
    func sign(parameters: [String: Any]) -> [String: Any] {
        var parameters = parameters;
        
        parameters["sessionId"] = Date().timeIntervalSince1970
        
        parameters["mCode"] = device.uuid
        
        parameters["authId"] = "a7a19b705ce5c483"
        
        var formattedParamters = [String]();
        
        for (key, value) in parameters {
            let formatted = "\(key)=\(value)&"
            
            formattedParamters.append(formatted)
        }
        
        formattedParamters.sort{ $0.caseInsensitiveCompare($1) == .orderedAscending}
        
        var result = formattedParamters.joined(separator: "")
        
        result = "\(result)key=c3c2ba77b7bb1c811998f818c578061f"
        
        let sign = result.md5()
        
        parameters["sign"] = sign
        
        
        return parameters
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
        default:break
        }
        
        return path
    }
    
    var baseURL: URL {
        return URL(string: "http://www.i-billing.com.cn:8081/ibillingplatform")!
    }
    
    var method: Moya.Method {
        return .post
    }
}
