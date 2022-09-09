//
//  PersonDB.swift
//  TestSQLite
//
//  Created by beforeold on 2022/9/9.
//

import Foundation
import FMDB

public class PersonDB {
    public static let shared = PersonDB()
    
    private let db: FMDatabaseQueue?
    
    private init() {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path += "/demo.sqlite"
        db = FMDatabaseQueue(path: path)
    }
    
    public func getCount() {
        print("begin")

        var count = 0
        
        db?.inDatabase({ db in
            do {
                let sql = "SELECT COUNT(*) as count FROM T_PERSON"
                let res = try db.executeQuery(sql, values: nil)

                while res.next() {
                    let int = res.int(forColumnIndex: 0)
                    count = Int(int)
                }
            } catch {
                
            }
        })
        
        print(count)
        
        print("end")
    }
}
