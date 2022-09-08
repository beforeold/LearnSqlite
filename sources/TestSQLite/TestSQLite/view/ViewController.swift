//
//  ViewController.swift
//  TestSQLite
//
//  Created by beforeold on 2022/9/7.
//

import UIKit
import SwiftUI
import SQLite3

class ViewController: UIHostingController<BodyView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder,
                   rootView: BodyView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        setupDB()
    }
    
    // MARK: - private
    
    private func setupDB() {
        DBManager.shared.openDB(name: "demo.sqlite")
        DBManager.shared.createTable(name: "T_PERSON")
    }
}

