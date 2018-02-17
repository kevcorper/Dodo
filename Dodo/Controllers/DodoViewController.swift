//
//  ViewController.swift
//  Dodo
//
//  Created by Kevin Perkins on 2/12/18.
//  Copyright © 2018 Kevin Perkins. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class DodoViewController: SwipeTableViewController {
    
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
        tableView.separatorStyle = .none
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        guard let navigationColor = selectedCategory?.color else {fatalError("Unable to retrieve navigationColor")}
        updateNavBar(withHexCode: navigationColor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "77D4D4", withTextColor: "FFFFFF")
    }
    
    // MARK: Navbar setup methods
    
    func updateNavBar(withHexCode colorHexCode: String, withTextColor textColorHexCode : String = "") {
        guard let navbar = navigationController?.navigationBar else {fatalError("Unable to retrieve navBar")}
        guard let navigationColor = UIColor(hexString: colorHexCode) else {fatalError("Unable to create original navigation color")}
        let textColor : UIColor
        
        if textColorHexCode == "" {
            textColor = ContrastColorOf(navigationColor, returnFlat: true)
        } else {
            textColor = UIColor(hexString: textColorHexCode)!
        }
    
        navbar.barTintColor = navigationColor
        navbar.tintColor = textColor
        navbar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor]
        navbar.layer.borderColor = navigationColor.cgColor
        searchBar.barTintColor = navigationColor
        searchBar.tintColor = navigationColor
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = navigationColor.cgColor
    }
    
    // MARK: Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dodoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = dodoItems?[indexPath.row] {
            cell.textLabel?.text = item.name
            cell.accessoryType = item.finished ? .checkmark : .none
            
            if let color = UIColor(hexString: (selectedCategory!.color))?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(dodoItems!.count)) {
                    cell.backgroundColor = color
                    cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                    cell.tintColor = ContrastColorOf(color, returnFlat: true)
            }
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
    
    override func deleteFromModel(at indexPath: IndexPath) {
        if let itemToDelete = self.dodoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemToDelete)
                }
            } catch {
                print("could not delete item, \(error)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = super.tableView(tableView, editActionsOptionsForRowAt: indexPath, for: orientation)
        options.expansionStyle = .destructive
        return options
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


class CustomTableViewCell: UITableViewCell
{
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
}

