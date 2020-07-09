//
//  NeedsViewController.swift
//  Swappy
//
//  Created by Sean Cuvanov on 4/7/20.
//  Copyright © 2020 Sean Cuvanov. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwipeCellKit

class FeedViewController: UIViewController {
    
    var dataManager = DataManager()
    var items: [Item] = []
    var tempItems: [Item] = []
    var selectedItem: Item?
    
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
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
        
        let itemSearchCriteria = ItemSearchCriteria(owner: (Auth.auth().currentUser?.uid)!, category: Item.Category.STOCK, skipOwner: true, filterAvailable: true)
        
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
    
    func swap(selectedItem: Item) {
        self.selectedItem = selectedItem
        self.performSegue(withIdentifier: Constants.Segue.FEED_TO_CREATE_TRADE, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.FEED_TO_CREATE_TRADE {
            let destinationVC = segue.destination as! SwapViewController
            destinationVC.selectedItem = selectedItem
        }
    }
}

//MARK: - SEARCH BAR DELEGATE

extension FeedViewController: UISearchBarDelegate {
    
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

extension FeedViewController: UITableViewDataSource {
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

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let cell = self.tableView.cellForRow(at: indexPath) as! ItemTableViewCell
         cell.showSwipe(orientation: .right, animated: true, completion: nil)
    }
}

extension FeedViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let item = self.items[indexPath.row]
        
        let swapAction = SwipeAction(style: .default, title: "Swap") { action, indexPath in
            self.swap(selectedItem: item)
        }

        swapAction.image = UIImage(systemName: "arrow.swap")
        swapAction.backgroundColor = .systemBlue
        
        return [swapAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .border
        options.expansionStyle = .none
        return options
    }
}
