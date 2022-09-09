//
//  BodyView.swift
//  TestSQLite
//
//  Created by beforeold on 2022/9/8.
//

import SwiftUI

struct BodyView: View {
    @State private var currentCount = 0
    @State private var latestRecords = [Person]()
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Button("Insert One", action: insertOne)
                }
                HStack {
                    Text("current count: \(currentCount)")
                    Button("refresh", action: refreshCount)
                }
                Button("insert many") {
                    Person.insertMany()
                }
                Button("insert many with transaction") {
                    Person.insertManyWithTransaction()
                }
                
                Button("insert many with transaction and batch") {
                    Person.insertManyWithTransactionAndBatch()
                }
                
            }.padding()
            List(latestRecords, id: \.id) { p in
                HStack {
                    Text("\(p.id): \(p.name), \(p.age)")
                }
            }
        }.onAppear {
            // DispatchQueue.main.asyncAfter(deadline: .now() + 1,
               //                           execute: refreshCount)
        }
    }
    
    private func refreshCount() {
        Person.getLatestTen { totalCount, persons in
            currentCount = totalCount
            latestRecords = persons
        }
    }
    
    private func insertOne() {
        DBManager.shared.withDBQueue { _ in
            let person = Person(age: 88, name: "beforeold")
            person.inserted()
        }
        refreshCount()
    }
}

struct BodyView_Previews: PreviewProvider {
    static var previews: some View {
        BodyView()
    }
}
