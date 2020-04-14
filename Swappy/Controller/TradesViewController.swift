//
//  StockViewController.swift
//  Swappy
//
//  Created by Sean Cuvanov on 4/7/20.
//  Copyright © 2020 Sean Cuvanov. All rights reserved.
//

import UIKit
import FirebaseAuth

class TradesViewController: UIViewController {
    
    var dataManager = DataManager()
    var trades: [Trade] = []
    
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.Cell.ITEM_CELL_NIB_NAME, bundle: nil), forCellReuseIdentifier: Constants.Cell.CELL_IDENTIFIER)
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
        /*
        let itemSearchCriteria = ItemSearchCriteria(owner: (Auth.auth().currentUser?.uid)!, category: Item.Category.STOCK)
        
        dataManager.listenForItems(searchCriteria: itemSearchCriteria) { (items) in
            self.trades = items
            self.tempItems = items
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.searchBar.resignFirstResponder()
                self.searchBar.text = ""
                
                if self.trades.count - 1 >= 0 {
                    let indexPath = IndexPath(row: self.trades.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            }
        }
         */
    }
}

//TODO: Need to switch off the ItemTableViewCell and get into a TradeTableViewCell

//MARK: - TABLEVIEW DATA SOURCE
extension TradesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trades.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = trades[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.CELL_IDENTIFIER, for: indexPath) as! TradeTableViewCell
        
        //cell.nameLabel.text = item.name
        //cell.countLabel.text = String(item.count)
        
        return cell
    }
}
