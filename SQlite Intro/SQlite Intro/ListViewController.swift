//
//  ListViewController.swift
//  SQlite Intro
//
//  Created by QuietGrowth pty ltd on 29/07/19.
//  Copyright © 2019 Mrajsingh. All rights reserved.
//

import UIKit
import SQLite3

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    var db: OpaquePointer?
    var name = [Int:String]()
    var nameArray = [String]()
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("testDatabase.sqlite")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openAndCreateDatabase()
        fetchDataFromDatabase()
        // Do any additional setup after loading the view.
    }
    

}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        cell.nameLabel.text = nameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //this gets keys from the value
            let key  =  name.filter {
                return $0.1.contains(nameArray[indexPath.row])
                }.map {
                    return $0.0
            }
            self.name.removeValue(forKey: key[0])
            self.nameArray.remove(at: indexPath.row)
            deleteDatafromDataBase(itemId: key[0])
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alertWithTextField(title: "Upadate Name", message: "", placeholder: "Name") { (textValue) in
            let key  =  self.name.filter {
                return $0.1.contains(self.nameArray[indexPath.row])
                }.map {
                    return $0.0
            }
            self.updateValue(value: textValue, id: key[0])
        }
    }
    
    
}



extension ListViewController {
    

    
    
    //Step 1:- open and create database
    func openAndCreateDatabase(){
        if sqlite3_open(fileURL.path, &db)  != SQLITE_OK {
            print("Error opening database.")
            return
        }
        
        let createTableQuery = "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY AUTOINCREMENT, firstName TEXT, lastName TEXT)"
        
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating table")
            return
        }
        
        print("Data Base creeated and opened")
    }
    
    //Step 2:- fetch data from database
    func fetchDataFromDatabase(){
        let queryStatementString = "SELECT * FROM test;"
        var queryStatement: OpaquePointer? = nil
        // 1
        
        name.removeAll()
        nameArray.removeAll()
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                    let id = sqlite3_column_int(queryStatement, 0)
                    // 4
                    let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                    let firstName = String(cString: queryResultCol1!)

                    name[Int(id)] = firstName
                    nameArray.append(firstName)
                    // 5
                    
                    print("Query Result:")
                    print("\(id) | \(firstName)")
                }
                
              // name =  Dictionary(uniqueKeysWithValues: )
                print(Dictionary(uniqueKeysWithValues: name.sorted(by: { (adict, bdict) -> Bool in
                    adict.key < bdict.key
                })))
                
                print(name)
  
            } else {
                print("Query returned no results")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        // 6
        sqlite3_finalize(queryStatement)
        
        self.tableView.reloadData()
        
    }
    
    
    func deleteDatafromDataBase(itemId: Int){
        let deleteStatementStirng = "DELETE FROM test WHERE id = ?;"
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(deleteStatement, 1, Int32(itemId))
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
        
        
    }
    
     func alertWithTextField(title: String? = nil, message: String? = nil, placeholder: String? = nil, completion: @escaping ((String) -> Void) = { _ in }) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField() { newTextField in
            newTextField.placeholder = placeholder
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completion("") })
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            if
                let textFields = alert.textFields,
                let tf = textFields.first,
                let result = tf.text
            { completion(result) }
            else
            { completion("") }
        })
        navigationController?.present(alert, animated: true)
    }
    
    
    
    func updateValue(value:String, id: Int){
        let updateStatementString = "UPDATE test SET firstName = '\(value)' WHERE id = '\(id)';"
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared")
        }
        fetchDataFromDatabase()
        self.tableView.reloadData()
        sqlite3_finalize(updateStatement)
    }
    
    
}
