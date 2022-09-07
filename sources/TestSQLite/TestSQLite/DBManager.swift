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

/// getDocumentsDirectory URL
///
/// @discussion same as NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
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
    
    public func query(sql: String) -> [[String: Any]] {
        let cSql = sql.cString(using: .utf8)
        var stmt: OpaquePointer?
        let ret = sqlite3_prepare_v2(db, cSql, -1, &stmt, nil)
        ret.retPrinted("query")
        
        guard let stmt = stmt else {
            return []
        }

        var list = [[String: Any]]()
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            let map = fetch(stmt)
            list.append(map)
        }
        return list
    }
    
    private func fetch(_ stmt: OpaquePointer) -> [String: Any] {
        let count = sqlite3_column_count(stmt)
        
        var map = [String: Any]()
        
        for columIndex in 0..<count {
            let cName = sqlite3_column_name(stmt, columIndex)
            let name = String(cString: cName!)
            let type = sqlite3_column_type(stmt, columIndex)
            
            var value: Any
            
            switch type {
            case SQLITE_INTEGER:
                value = Int(sqlite3_column_int64(stmt, columIndex))
                
            case SQLITE_FLOAT:
                value = sqlite3_column_double(stmt, columIndex)
                
            case SQLITE3_TEXT:
                let sString = sqlite3_column_text(stmt, columIndex)!
                value = String(cString: sString)
            default:
                value = NSNull()
            }
            
            map[name] = value
        }
        
        return map
    }
}
