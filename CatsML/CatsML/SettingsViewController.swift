//
//  SettingsViewController.swift
//  CatsML
//
//  Created by CW2519 on 1/6/20.
//  Copyright © 2020 lena. All rights reserved.
//

import UIKit

enum SettingsKeys: String {
    case usingGenericModel
}

class SettingsViewController: UITableViewController {
    @IBOutlet weak var switch1: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        switch1.isOn = UserDefaults.standard.bool(forKey: SettingsKeys.usingGenericModel.rawValue)
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */


    @IBAction func switch1ValueChanged(_ sender: Any) {
        UserDefaults.standard.set(switch1.isOn, forKey: SettingsKeys.usingGenericModel.rawValue)
    }
}
