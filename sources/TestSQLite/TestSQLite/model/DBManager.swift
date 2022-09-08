//
//  DBManager.swift
//  TestSQLite
//
//  Created by beforeold on 2022/9/7.
//

import Foundation
import SQLite3


fileprivate let enablesPrint = false

fileprivate  extension Int32 {
    func retPrinted(_ msg: String) {
        ooprint("\(msg) isSucess: \(self == SQLITE_OK)")
    }
}

fileprivate func ooprint(_ msg: String) {
    guard enablesPrint else { return }
    
    print(msg)
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
            ooprint("db path: \(path)")
            
            let ret = sqlite3_open(path, &self.db)
            ret.retPrinted("open db")
        }
    }
    
    public func dbExecute(task: @escaping () -> Void) {
        queue.async(execute: task)
    }
    
    public func execute(sql: String) {
        dbExecute {
            self._execute(sql: sql)
        }
    }
    
    public func beginTransaction() {
        _execute(sql: "BEGIN TRANSACTION")
    }
    
    public func commitTransaction() {
        _execute(sql: "COMMIT TRANSACTION")
    }
    
    public func rollbackTransaction() {
        _execute(sql: "ROLLBACK TRANSACTION")
    }
    
    func _execute(sql: String) {
        let cSql = sql.cString(using: .utf8)
        var errorMsg: UnsafeMutablePointer<CChar>?
        let ret = sqlite3_exec(self.db, cSql, nil, nil, &errorMsg)
        var msg = "done"
        if let errorMsg = errorMsg {
            let string = String(cString: errorMsg)
            msg = string
        }
        ret.retPrinted("[\(sql)]")
        ooprint("end msg: \(msg)")
    }
    
    /// for same name C macro define
    private var SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    func batch(sql: String, args: CVarArg...) {
        let cSql = sql.cString(using: .utf8)
        
        var stmt: OpaquePointer?
        sqlite3_prepare_v2(db, cSql, -1, &stmt, nil)
        
        guard let stmt = stmt else {
            ooprint("failed to prepare stmt")
            return
        }

        for (index, arg) in args.enumerated() {
            let seq = Int32(index + 1)
            if let int = arg as? Int64 {
                sqlite3_bind_int64(stmt, seq, int)
            }
            else if let double = arg as? Double {
                sqlite3_bind_double(stmt, seq, double)
            }
            else if let string = arg as? String {
                let cString = string.cString(using: .utf8)!
                sqlite3_bind_text(stmt, seq, cString, -1, SQLITE_TRANSIENT)
            }
            else {
                // 暂不处理
            }
        }
        
        defer {
            sqlite3_finalize(stmt)
        }
        
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            return
        }
        
        guard sqlite3_reset(stmt) == SQLITE_OK else {
            return
        }
        
        // over to sqlite3_finalize
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
        
        sqlite3_finalize(stmt)
        
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
