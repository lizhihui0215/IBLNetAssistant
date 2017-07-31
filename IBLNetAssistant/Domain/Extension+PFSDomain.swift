//
//  Extension+PFSDomain.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 19/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit

import PCCWFoundationSwift

extension PFSDomain {
    
    
    public static func login(user: IBLUser?) {
        IBLDataRepository.shared.put(key: "user", value: user)
    }
    
    public static func login() -> IBLUser? {
        return IBLDataRepository.shared.get(key: "user")
    }
    
    func account(_ account: String?) {
        IBLDataRepository.shared.cache(key: "account", value: account)
    }
    
    func account() -> String? {
        return IBLDataRepository.shared.cache(key: "account")
    }
    
}
