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
        VStack {
            HStack {
                Text("current count: \(currentCount)")
                Button("refresh") {
                    
                }
            }
        }
    }
}

struct BodyView_Previews: PreviewProvider {
    static var previews: some View {
        BodyView()
    }
}
