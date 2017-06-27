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

enum IBLAPIClient: PFSTargetType {
    case login
    
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
        return ""
    }
    
    var baseURL: URL {
        return URL(string: "")!
    }
    
    var method: Moya.Method {
        return .post
    }
}
