//
//  DBManager.swift
//  TestSQLite
//
//  Created by beforeold on 2022/9/7.
//

import Foundation
import SQLite3


fileprivate  extension Int32 {
    func retPrinted(_ msg: String) {
        print("\(msg) isSucess: \(self == SQLITE_OK)")
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

public class DBManager {
    public static let shared = DBManager()
    
    private let queue = DispatchQueue(label: "com.beforeold.dbmanager")
    
    private init() {
        
    }
    
    private var db: OpaquePointer?
    
    public func openDB(name: String) {
        dbExecute {
            var path = getDocumentsDirectory().path
            path = (path as NSString).appendingPathComponent(name) as String
            print("db path: \(path)")
            
            let ret = sqlite3_open(path, &self.db)
            ret.retPrinted("open db")
        }
    }
    
    public func dbExecute(task: @escaping () -> Void) {
        queue.async(execute: task)
    }
    
    public func execute(sql: String) {
        dbExecute {
            let cSql = sql.cString(using: .utf8)
            var errorMsg: UnsafeMutablePointer<CChar>?
            let ret = sqlite3_exec(self.db, cSql, nil, nil, &errorMsg)
            var msg = "done"
            if let errorMsg = errorMsg {
                let string = String(cString: errorMsg)
                msg = string
            }
            ret.retPrinted("[\(sql)]")
            print("end msg: \(msg)")
        }
    }
  
    public func createTable(name: String) {
        let sql = """
CREATE TABLE IF NOT EXISTS \(name)(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
age INTEGER DEFAULT 18
)
"""
        execute(sql: sql)
    }
}
