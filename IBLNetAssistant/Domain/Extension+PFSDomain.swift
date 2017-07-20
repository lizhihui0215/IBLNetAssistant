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
    
    
    public func login(user: IBLUser) {
        return IBLDataRepository.shared.put(key: "user", value: user)
    }
    
    public func login() -> IBLUser? {
        return IBLDataRepository.shared.get(key: "user")
    }
    
}
