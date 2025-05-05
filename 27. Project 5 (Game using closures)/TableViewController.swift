//
//  ViewController.swift
//  27. Project 5 (Game using closures)
//
//  Created by Валентин Картошкин on 05.05.2025.
//

import UIKit

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }


}

