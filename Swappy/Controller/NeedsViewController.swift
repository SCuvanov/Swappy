//
//  NeedsViewController.swift
//  Swappy
//
//  Created by Sean Cuvanov on 4/7/20.
//  Copyright © 2020 Sean Cuvanov. All rights reserved.
//

import UIKit
import FirebaseAuth

class NeedsViewController: UIViewController {
    
    var dataManager = DataManager()
    var items: [Item] = []
    var tempItems: [Item] = []
    
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
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
        
        let itemSearchCriteria = ItemSearchCriteria(owner: (Auth.auth().currentUser?.uid)!, category: Item.Category.NEED)
        
        dataManager.listenForItems(searchCriteria: itemSearchCriteria) { (items) in
            self.items = items
            self.tempItems = items
            
            print(items)
            
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
                let newItem = Item(name: name, owner: owner, count: count, category: Item.Category.NEED)
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

extension NeedsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if items.count > 0 {
            items = items.filter { $0.name.contains(searchBar.text!) }
            tableView.reloadData()
        }
    }
    
    //TODO: What to do when its empty
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

extension NeedsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.CELL_IDENTIFIER, for: indexPath) as! ItemTableViewCell
        
        cell.nameLabel.text = item.name
        cell.countLabel.text = String(item.count)
        
        return cell
    }
}
