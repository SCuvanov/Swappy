//
//  CreateTradeViewController.swift
//  Swappy
//
//  Created by Sean Cuvanov on 4/17/20.
//  Copyright © 2020 Sean Cuvanov. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwipeCellKit

class SwapViewController: UIViewController, ItemSelectionViewControllerDelegate {

    var selectedItem: Item?
    var originalItem: Item?
    
    var dataManager = DataManager()
    var items: [Item] = []
    var tempItems: [Item] = []
    var selectedItems: [String: Item] = [:]
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.register(UINib(nibName: Constants.Cell.ITEM_CELL_NIB_NAME, bundle: nil), forCellReuseIdentifier: Constants.Cell.CELL_IDENTIFIER)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let name = selectedItem?.name, let count = selectedItem?.count {
            nameLabel.text = name
            countLabel.text = String(count)
        }
        
        originalItem = selectedItem
    }
    
    @IBAction func editItemButtonPressed(_ sender: UIButton) {
        var countTextField = UITextField()
        
        let alert = UIAlertController(title: "Edit Item", message: "Modify the details of the Item you want to swap for.", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Count"
            countTextField = alertTextField
        }
        
        let action = UIAlertAction(title: "Submit", style: .default) { (action) in
            if let count = Int(countTextField.text!) {
                self.selectedItem?.count = count
                self.countLabel.text = String(count)
            }
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: Constants.Segue.CREATE_TRADE_TO_ITEM_SELECTION, sender: self)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        //TODO: Build Trade Object, Post to DB
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
                
                //self.update(item: item)
            }
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == Constants.Segue.CREATE_TRADE_TO_ITEM_SELECTION){
            let isVC = segue.destination as! ItemSelectionViewController
            isVC.delegate = self
            isVC.selectedItems = selectedItems
        }
    }
    
    func setSelectedItems(selectedItems: [String : Item]) {
        self.items = Array(selectedItems.values)
        self.selectedItems = selectedItems
        tableView.reloadData()
    }
}

extension SwapViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.CELL_IDENTIFIER, for: indexPath) as! ItemTableViewCell
        
        cell.delegate = self
        
        cell.nameLabel.text = item.name
        cell.countLabel.text = String(item.count)
        cell.statusStackView.isHidden = true
        
        return cell
    }
}

extension SwapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! ItemTableViewCell
        cell.showSwipe(orientation: .right, animated: true, completion: nil)
    }
}

extension SwapViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
    
        let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
            self.edit(at: indexPath)
        }
        
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemBlue
        
        return [editAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .border
        options.expansionStyle = .none
        return options
    }
}
