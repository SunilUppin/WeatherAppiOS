//
//  HomeVC.swift
//  EnParadigmWeatherApp
//
//  Created by Sunil on 22/09/20.
//  Copyright © 2020 User. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = UIImageView(image: UIImage(named: "daytimeClear"))
        tableView.register(UINib(nibName: "LocationName", bundle: nil), forCellReuseIdentifier: "LocationNameCell")
        tableView.register(UINib(nibName: "NextDaysWeatherInfo", bundle: nil), forCellReuseIdentifier: "NextDaysWeatherInfoCell")
        tableView.tableFooterView = UIView()
    }

}

extension HomeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationNameCell", for: indexPath) as! LocationNameCell
            cell.layer.backgroundColor = UIColor.clear.cgColor
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NextDaysWeatherInfoCell", for: indexPath) as! NextDaysWeatherInfoCell
            cell.layer.backgroundColor = UIColor.clear.cgColor
            return cell
        }
    }
    
    
}
