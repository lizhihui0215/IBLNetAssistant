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

    var parameters: [String: Any]? {
        return []
    }
    var parameterEncoding: ParameterEncoding {
        return nil
    }
    var sampleData: Data {
        return nil
    }
    var task: Task {
        return nil
    }
    var validate: Bool {
        return false
    }


    var path: String {
        return ""
    }

    
    case login
    
    var baseURL: URL {
        return URL(string: "")!
    }
    
    var method: Moya.Method {
        return .post
    }
    

}
