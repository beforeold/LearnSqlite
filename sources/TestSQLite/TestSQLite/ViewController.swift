//
//  ViewController.swift
//  TestSQLite
//
//  Created by beforeold on 2022/9/7.
//

import UIKit
import SQLite3

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        setupDB()
    }
    
    private func setupDB() {
        DBManager.shared.openDB(name: "demo.sqlite")
        DBManager.shared.createTable(name: "T_PERSON")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }

}

