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
        DBManager.shared.execute(sql: sql)
    }
}
