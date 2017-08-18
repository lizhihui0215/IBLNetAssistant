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
import Alamofire
import RxSwift
import RxCocoa

private var APIBaseURL = ""

public func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}

enum IBLAPITarget: PFSTargetType {


    case school(CLLocationCoordinate2D)
    case auth(String, String)
    case register(String, IBLSchool)
    case portal(String)
    case portalAuth(String, String, [String : Any])
    case web([String : Any])
    case registerAccount
    case logout(String, [String : Any])
    case sms(String, String)
    case exchangePassword(String, String, String, String)
    case offline(String, String, String)
    
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
            if let v = value as? String, v == "" {
                continue
            }
            
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
        case let .school(locationCoordinate2D):
            parameters = ["longit" : "\(locationCoordinate2D.longitude)", "lati" : "\(locationCoordinate2D.latitude)"]
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
        case let .sms(account, phone):
            let param = ["account" : account, "mobile" : phone]
            parameters = sign(parameters: param)
        case let .exchangePassword(account, phone, sms, password):
            let param = ["account" : account, "mobile" : phone, "vcode" : sms, "password" : password]
            parameters = sign(parameters: param)
        case .registerAccount:
            let param = ["clientType" : "0"]
            parameters = sign(parameters: param)
        case let .offline(_, account, userip):
            let param = ["account" : account,
                         "userip" : userip]
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
        case .school:
            path = "userservice/getschoollist.do"
        case .auth(_,_):
            path = "ibillingportal/userservice/auth.do"
        case .register(_,_):
            path = "nodeibilling/httpservices/user/appRegister.do"
        case .web(_):
            path = "ibillingportal/userservice/index.do"
        case .sms:
            path = "nodeibilling/httpservices/user/getSmsCode.do"
        case .exchangePassword:
            path = "nodeibilling/httpservices/user/smsModifyPwd.do"
        case .registerAccount:
            path = "ibillingportal/userservice/regAccount.do"
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
        case .school:
            return URL(string: "http://www.i-billing.com.cn:8081/ibillingplatform")!
        case let .offline(kickurl, _, _):
            return URL(string: kickurl)!
        default:
            return URL(string: APIBaseURL)!
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .web(_): fallthrough
        case .registerAccount:
            return .get
        default:
            return .post
        }
    }
}

public func reachable(url: String) -> Driver<Bool> {
    let reachable = PublishSubject<Bool>()
    
    do {
        var request = try URLRequest(url: URL(string: url)!, method: .head, headers: nil)
        request.timeoutInterval = 5
        Alamofire.request(request).responseString {
            response in
            reachable.onNext(response.error == nil)
        }
    } catch {
        reachable.onNext(false)
    }
    
    return reachable.asObservable().asDriver(onErrorJustReturn: false)
}


