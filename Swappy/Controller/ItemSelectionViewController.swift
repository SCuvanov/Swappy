//
//  ItemSelectionViewController.swift
//  Swappy
//
//  Created by Sean Cuvanov on 5/16/20.
//  Copyright © 2020 Sean Cuvanov. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwipeCellKit

class ItemSelectionViewController: UIViewController {
    
    var dataManager = DataManager()
    var items: [Item] = []
    var selectedItems: [String: Item] = [:]
    
    var delegate : ItemSelectionViewControllerDelegate?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.register(UINib(nibName: Constants.Cell.ITEM_CELL_NIB_NAME, bundle: nil), forCellReuseIdentifier: Constants.Cell.CELL_IDENTIFIER)

        listenForItems()
    }
        
    func listenForItems() {
        
        let itemSearchCriteria = ItemSearchCriteria(owner: (Auth.auth().currentUser?.uid)!, category: Item.Category.STOCK)
        
        dataManager.listenForItems(searchCriteria: itemSearchCriteria) { (items) in
            
            var tempItems = items
            
            for (index, item) in items.enumerated() {
                if(self.selectedItems[item.id!] != nil) {
                    var newItem = item
                    newItem.selected = true
                    
                    tempItems[index] = newItem
                 }
            }
            
            self.items = tempItems
        
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
                if self.items.count - 1 >= 0 {
                    let indexPath = IndexPath(row: self.items.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            }
        }
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        delegate?.setSelectedItems(selectedItems: selectedItems)
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - TABLEVIEW DATA SOURCE

extension ItemSelectionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.CELL_IDENTIFIER, for: indexPath) as! ItemTableViewCell
        
        cell.nameLabel.text = item.name
        cell.countLabel.text = String(item.count)
        cell.statusStackView.isHidden = true
        cell.accessoryType = item.selected ? .checkmark : .none

        return cell
    }
}

extension ItemSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! ItemTableViewCell
        cell.showSwipe(orientation: .right, animated: true, completion: nil)
        
        items[indexPath.row].selected = !items[indexPath.row].selected
        let item = items[indexPath.row]
        
        cell.accessoryType = item.selected ? .checkmark : .none
    
        if(!item.selected){
            selectedItems[item.id!] = nil
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            selectedItems[item.id!] = item
        }
    }
}

protocol ItemSelectionViewControllerDelegate {
    func setSelectedItems(selectedItems: [String: Item])
}
