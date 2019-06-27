//
//  ViewController.swift
//  ToDoey
//
//  Created by Eugene Razorenov on 28/05/2019.
//  Copyright © 2019 Eugene Razorenov. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class TodoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    //MARK: - Application Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.title = selectedCategory?.name
        guard let colorHex = selectedCategory?.cellColor else {fatalError()}
        
        updateNavBar(withHexCode: colorHex)
        
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "1D9BF6")

    }
    
    
    
    //MARK - Nav Bar Setup Methods
    func updateNavBar(withHexCode colorHexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        guard let navBarColor  = UIColor(hexString: colorHexCode) else {fatalError()}
        navBar.barTintColor    = navBarColor
        navBar.tintColor       = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor = navBarColor
        
    }
    
    
    
    
    //MARK - Tableview Data Sourse Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        return todoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType   = item.done ? .checkmark : .none
            
            if let itemColor = UIColor(hexString: selectedCategory!.cellColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = itemColor
                cell.textLabel?.textColor = ContrastColorOf(itemColor, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    
    
    // MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
//                    realm.delete(item)
                }
            } catch {
                print("Error saving done status, \(error.localizedDescription)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
    // MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField   = UITextField()
        let alert       = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action      = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem    = Item()
                        newItem.title  = textField.text!
                        newItem.dateCreated = Date()
                        
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving items, \(error.localizedDescription)")
                }
                
            }
            
            self.tableView.reloadData()            
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    // MARK - Model Manipulating Methods
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting this item, \(error.localizedDescription)")
            }
        }
        
    }
    
}



//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[CD] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
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
