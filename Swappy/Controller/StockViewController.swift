//
//  StockViewController.swift
//  Swappy
//
//  Created by Sean Cuvanov on 4/7/20.
//  Copyright © 2020 Sean Cuvanov. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwipeCellKit

class StockViewController: UIViewController {
    
    var dataManager = DataManager()
    var items: [Item] = []
    var tempItems: [Item] = []
    
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.register(UINib(nibName: Constants.Cell.ITEM_CELL_NIB_NAME, bundle: nil), forCellReuseIdentifier: Constants.Cell.CELL_IDENTIFIER)
        
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.clear
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Futura-Bold", size: 20)!]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        
        listenForItems()
    }
    
    func listenForItems() {
        
        let itemSearchCriteria = ItemSearchCriteria(owner: (Auth.auth().currentUser?.uid)!, category: Item.Category.STOCK)
        
        dataManager.listenForItems(searchCriteria: itemSearchCriteria) { (items) in
            self.items = items
            self.tempItems = items
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.searchBar.resignFirstResponder()
                self.searchBar.text = ""
                
                if self.items.count - 1 >= 0 {
                    let indexPath = IndexPath(row: self.items.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            }
        }
    }
    
    func delete(at indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        
        self.items.remove(at: indexPath.row)
        dataManager.removeItemFromDB(item: item)
    }
    
    func update(item: Item) {
        dataManager.updateItemInDB(item: item)
    }
    
    func edit(at indexPath: IndexPath) {
        var nameTextField = UITextField()
        var countTextField = UITextField()
        
        let alert = UIAlertController(title: "Edit Item", message: "Enter the details to edit an Item you have in your stock.", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Name"
            nameTextField = alertTextField
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Count"
            countTextField = alertTextField
        }
        
        let action = UIAlertAction(title: "Submit", style: .default) { (action) in
            if let name = nameTextField.text, let count = Int(countTextField.text!) {
                var item = self.items[indexPath.row]
                
                item.name = name
                item.count = count
                
                self.update(item: item)
            }
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var nameTextField = UITextField()
        var countTextField = UITextField()
        
        let alert = UIAlertController(title: "Create Item", message: "Enter the details of an Item you have in your stock.", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Name"
            nameTextField = alertTextField
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Count"
            countTextField = alertTextField
        }
        
        let action = UIAlertAction(title: "Submit", style: .default) { (action) in
            if let name = nameTextField.text, let count = Int(countTextField.text!), let owner = Auth.auth().currentUser?.uid {
                let newItem = Item(name: name, owner: owner, count: count, category: Item.Category.STOCK)
                self.items.append(newItem)
                
                self.dataManager.addItemToDB(item: newItem)
                
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - SEARCH BAR DELEGATE

extension StockViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if items.count > 0 {
            items = items.filter { $0.name.contains(searchBar.text!) }
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            items = tempItems
            tableView.reloadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

//MARK: - TABLEVIEW DATA SOURCE

extension StockViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.CELL_IDENTIFIER, for: indexPath) as! ItemTableViewCell

        
        cell.delegate = self
        
        cell.nameLabel.text = item.name
        cell.countLabel.text = String(item.count)
        cell.statusLabel.text = item.status
        cell.statusImageView.tintColor = item.status == Item.Status.AVAILABLE ? .systemGreen : .systemYellow
        
        return cell
    }
}

extension StockViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let cell = self.tableView.cellForRow(at: indexPath) as! ItemTableViewCell
         cell.showSwipe(orientation: .right, animated: true, completion: nil)
    }
}

extension StockViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        var item = self.items[indexPath.row]

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.delete(at: indexPath)
        }
        
        let status = item.status == Item.Status.AVAILABLE ? Item.Status.UNAVAILABLE : Item.Status.AVAILABLE
        item.status = status
        
        let toggleStatusAction = SwipeAction(style: .default, title: status) { action, indexPath in
            self.update(item: item)
        }
        
        let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
            self.edit(at: indexPath)
        }

        // customize the action appearance
        deleteAction.image = UIImage(systemName: "trash")
        
        toggleStatusAction.image = status == Item.Status.AVAILABLE ? UIImage(systemName: "tray.and.arrow.down.fill") : UIImage(systemName: "tray.and.arrow.up.fill")
        toggleStatusAction.backgroundColor = status == Item.Status.AVAILABLE ? .systemGreen : .systemYellow
        
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemBlue
        
        
        return [deleteAction, toggleStatusAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .border
        options.expansionStyle = .none
        return options
    }
}
