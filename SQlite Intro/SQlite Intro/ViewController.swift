//
//  ViewController.swift
//  SQlite Intro
//
//  Created by QuietGrowth pty ltd on 29/07/19.
//  Copyright © 2019 Mrajsingh. All rights reserved.
//

import UIKit
import SQLite3


class ViewController: UIViewController {

    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var db: OpaquePointer?
    
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("testDatabase.sqlite")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        openAndCreateDatabase()
        errorLabel.text = ""
        
    }
    
    
    

    @IBAction func save_Data_pressed(_ sender: UIButton) {
        if let fn = firstNameLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            
            if fn.isEmpty {
                errorLabel.text = "Please provide name"
            } else {
                errorLabel.text = ""
              insertDataInDatabase(firstName: fn)
            }
            
        }
        
    }
    
    
    
    @IBAction func show_saved_data_pressed(_ sender: UIButton) {
        //perform seegue here
        self.performSegue(withIdentifier: "show_List", sender: nil)
    }
    
    
    
    
}


extension ViewController {
    

    
    // this inserts a value in database
    func insertDataInDatabase(firstName:String){
        
        var statement: OpaquePointer?
        let insertQuery = "INSERT INTO test (firstName) VALUES (?)"
        
        if sqlite3_prepare(db, insertQuery, -1, &statement, nil) != SQLITE_OK {
            print("Error binding the query")
        }
        
        if sqlite3_bind_text(statement, 1, firstName, -1, nil) != SQLITE_OK {
            print("error binding firstname")
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Test saved successfully")
        } else {
            print("error in inserting values")
        }
        
        let alert = UIAlertController(title: "Save Successfully!", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
        self.navigationController?.present(alert, animated: true)
    }
    
    
    
    //this function cretes the database and opens it.
    func openAndCreateDatabase(){
        if sqlite3_open(fileURL.path, &db)  != SQLITE_OK {
            print("Error opening database.")
            return
        }
        
        let createTableQuery = "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY AUTOINCREMENT, firstName TEXT)"
        
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating table")
            return
        }
        
        print("Data Base creeated and opened")
    }
    
    
    
    

}


extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

