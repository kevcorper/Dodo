//
//  ViewController.swift
//  Dodo
//
//  Created by Kevin Perkins on 2/12/18.
//  Copyright © 2018 Kevin Perkins. All rights reserved.
//

import UIKit
import RealmSwift

class DodoViewController: UITableViewController {
    
    var dodoItems : Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadItems()
    }
    
    // MARK: Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dodoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DodoItemCell", for: indexPath)
        
        if let item = dodoItems?[indexPath.row] {
            cell.textLabel?.text = item.name
            cell.accessoryType = item.finished ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items have been added yet!"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = dodoItems?[indexPath.row] {
            do {
                try self.realm.write{
                    item.finished = !item.finished
                }
            } catch {
                print("Error saving finished status: \(error)")
            }
        }
        tableView.reloadData()
    }
    
    // MARK: add new item

    @IBOutlet weak var searchBar: UISearchBar!
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new item to this Dodo", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write{
                        let newItem = Item()
                        newItem.name = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving item: \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Buy more ice cream"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: load data methods
    
    func loadItems() {
        dodoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
}

// MARK: search bar methods
extension DodoViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dodoItems = dodoItems?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


