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
}

extension Person {
    func inserted() {
        let sql = """
INSERT INTO T_PERSON
       (age, name)
       VALUES
       (\(age), '\(name)')
"""
        DBManager.shared._execute(sql: sql)
    }
}

extension Person {
    static func queryAll() {
        let sql = """
SELECT * FROM T_Person ORDER BY age
"""
        let ret = DBManager.shared.query(sql: sql)
        print(ret)
    }
    
    static func insertMany() {
        let start = CFAbsoluteTimeGetCurrent()
        for i in 0..<10_000 {
            let p = Person(age: i, name: "bo-\(i)")
            p.inserted()
        }
        print("diff \(CFAbsoluteTimeGetCurrent() - start)")
    }
    
    static func insertManyWithTransaction() {
        let start = CFAbsoluteTimeGetCurrent()
        DBManager.shared.beginTransaction()
        for i in 0..<10_000 {
            let p = Person(age: i, name: "bo-\(i)")
            p.inserted()
        }
        DBManager.shared.commitTransaction()
        print("diff \(CFAbsoluteTimeGetCurrent() - start)")
    }
}
