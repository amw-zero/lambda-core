//
//  HomeViewController.swift
//  LambdaCore
//
//  Created by Alex Weisberger on 12/5/18.
//  Copyright © 2018 vts. All rights reserved.
//

import UIKit
import LambdaCoreApplication
class HomeViewController: UIViewController, Orchestratable {
    @IBOutlet weak var tableView: UITableView!
    var orchestrator: LoginOrchestrator!
    var viewAssetsState: ViewAssetsState = ViewAssetsState()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "AssetsTVC", bundle: nil), forCellReuseIdentifier: "AssetsTVC")
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewAssetsState.assets.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetsTVC", for: indexPath) as! AssetTVC
        cell.titleLabel.text = viewAssetsState.assets[indexPath.row].name
        return cell
    }
}
