//
//  Person.swift
//  TestSQLite
//
//  Created by beforeold on 2022/9/7.
//

import Foundation

struct Person {
    var id: Int = -1
    var age: Int
    var name: String
    
    init(age: Int, name: String) {
        self.age = age
        self.name = name
    }
    
    init?(map: [String: Any]) {
        guard let name = map["name"] as? String,
              let age = map["age"] as? Int,
                let id = map["id"] as? Int
        else {
            return nil
        }
        self.id = id
        self.age = age
        self.name = name
    }
}

extension Person {
    static func createTable(name: String) {
        let sql = """
CREATE TABLE IF NOT EXISTS \(name)(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
age INTEGER DEFAULT 18
)
"""
        DBManager.shared.withDBQueue {
            $0.execute(sql: sql)
        }
    }
}

extension Person {
    func inserted() {
        let sql = """
INSERT INTO T_PERSON
       (age, name)
       VALUES
       (\(age), '\(name)')
"""
        DBManager.shared.execute(sql: sql)
    }
}

private let maxInsertCount = 1_000_000

extension Person {
    static func queryAll() {
        let sql = """
SELECT * FROM T_Person ORDER BY age
"""
        let ret = DBManager.shared.query(sql: sql)
        print(ret)
    }
    
    static func insertMany() {
        DBManager.shared.withDBQueue { _ in
            let start = CFAbsoluteTimeGetCurrent()
            for i in 0..<10_000 {
                let p = Person(age: i, name: "bo-\(i)")
                p.inserted()
            }
            print("diff \(CFAbsoluteTimeGetCurrent() - start)")
        }
    }
    
    static func insertManyWithTransaction() {
        DBManager.shared.withDBQueue { manager in
            let start = CFAbsoluteTimeGetCurrent()
            manager.beginTransaction()
            for i in 0..<maxInsertCount {
                let p = Person(age: i, name: "bo-\(i)")
                p.inserted()
            }
            manager.commitTransaction()
            print("diff \(CFAbsoluteTimeGetCurrent() - start)")
        }
    }
    
    static func insertManyWithTransactionAndBatch() {
        DBManager.shared.withDBQueue { manager in
            let start = CFAbsoluteTimeGetCurrent()
            manager.beginTransaction()
            for i in 0..<maxInsertCount {
                let p = Person(age: i, name: "bo-\(i)")
                let sql = """
    INSERT INTO T_PERSON
        (name, age)
        VALUES
        (?,?)
    """
                DBManager.shared.batchInsert(sql: sql, args: p.name, p.age)
            }
            manager.commitTransaction()
            print("diff \(CFAbsoluteTimeGetCurrent() - start)")
        }
    }
    
    static func getPersonCount(completion: @escaping (Int) -> Void) {
        let sql = """
SELECT COUNT(*) as count
FROM T_PERSON
"""
        DBManager.shared.withDBQueue {
            let count = $0.query(sql: sql).first?["count"] as? Int
            DispatchQueue.main.async {
                completion(count ?? 0)
            }
        }
    }
    
    static func getLatestTen(completion: @escaping (Int, [Person]) -> Void) {
        DBManager.shared.withDBQueue { manager in
            let sql = """
SELECT COUNT(*) AS totalCount
FROM T_PERSON
"""
            let totalCount = (manager.query(sql: sql).first?["totalCount"] as? Int) ?? 0
            let pageSize = 10
            let count = totalCount >= pageSize ? pageSize : totalCount
            let offset = totalCount - pageSize
            
            let sql2 = """
SELECT * FROM T_PERSON
LIMIT \(offset), \(count)
"""
            let list = manager.query(sql: sql2)
            let persons = list.compactMap((Person.init(map:)))
            DispatchQueue.main.async {
                completion(totalCount, persons)
            }
        }
    }
}
