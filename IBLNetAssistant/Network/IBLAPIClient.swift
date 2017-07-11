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

enum IBLAPIClient: PFSTargetType {
    case school
    case login
    
    func sign(parameters: [String: Any]) -> [String: Any] {
        var parameters = parameters;
        
        parameters["sessionId"] = Date().timeIntervalSince1970
        
        parameters["mCode"] = device.uuid
        
        parameters["authId"] = "a05e74898131bd1c"
        
        var formattedParamters = [String]();
        
        for (key, value) in parameters {
            let formatted = "\(key)=\(value)"
            
            formattedParamters.append(formatted)
        }
        
        formattedParamters.sort{ $0.caseInsensitiveCompare($1) == .orderedAscending}
        
        var result = formattedParamters.joined(separator: "")
        
        result = "\(result)key=48e5be901c6692bf46fd2bba3b04d56b"
        
        let sign = result.md5()
        
        parameters["sign"] = sign
        
        
        return parameters
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var parameters: [String: Any]? {
        return [:]
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
        case .school:
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
