//
//  CreateTradeViewController.swift
//  Swappy
//
//  Created by Sean Cuvanov on 4/17/20.
//  Copyright © 2020 Sean Cuvanov. All rights reserved.
//

import UIKit

class SwapViewController: UIViewController {
    
    var selectedItem: Item?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let name = selectedItem?.name, let count = selectedItem?.count {
            nameLabel.text = name
            countLabel.text = String(count)
        }
    }
    
    @IBAction func editItemButtonPressed(_ sender: UIButton) {
        
        print("WOWOOW")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
