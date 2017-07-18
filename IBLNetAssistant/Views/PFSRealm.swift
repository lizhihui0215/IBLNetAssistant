//
//  PFSRealm.swift
//  IBLNetAssistant
//
//  Created by 李智慧 on 16/07/2017.
//  Copyright © 2017 李智慧. All rights reserved.
//

import UIKit
import RealmSwift
import Result
import Moya


open class PFSRealm {

    private let realm: Realm
    
    public static let shared = PFSRealm()
    
    init() {
        self.realm = try! Realm()
    }
    
    public func save<T: Object>(obj: T) -> Result<T, MoyaError> {
        do {
            try realm.write { realm.add(obj) }
        } catch let error {
            return Result(error: MoyaError.underlying(error))
        }
        
        return Result(value: obj)
    }
    
    public func update<T: Object>(obj: T) -> Result<T, MoyaError> {
        do {
            try realm.write { realm.add(obj, update: true) }
        } catch let error {
            return Result(error: MoyaError.underlying(error))
        }
        
        return Result(value: obj)
    }

    func object<T: Object>() -> T? {
        return realm.objects(T.self).first
    }
    
    func object<T: Object, K>(_ forPrimaryKey: K) -> T? {
        return realm.object(ofType: T.self, forPrimaryKey: forPrimaryKey)
    }
}
