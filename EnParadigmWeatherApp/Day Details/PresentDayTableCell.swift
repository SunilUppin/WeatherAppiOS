//
//  PresentDayTableCell.swift
//  EnParadigmWeatherApp
//
//  Created by Sunil on 22/09/20.
//  Copyright © 2020 User. All rights reserved.
//

import Foundation
import UIKit

class PresentDayTableCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    var viewModel : WeatherViewModel?
    
    override func awakeFromNib() {
        collectionView.register(UINib(nibName: "HourlyDetailsCell", bundle: nil), forCellWithReuseIdentifier: "HourlyDetailsCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}

extension PresentDayTableCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.hourlyArray.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyDetailsCell", for: indexPath) as! HourlyDetailsCell
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.timeLabel.text = viewModel?.hourlyArray[indexPath.row]
        cell.temperatureLabel.text = viewModel?.hourlyTempArray[indexPath.row]
        if (viewModel?.hourlyImageData[indexPath.row].contains("cloud"))! {
            cell.imgSignView.image = UIImage(named: "dayCloudy")
        } else {
            cell.imgSignView.image = UIImage(named: "rainy")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100.0, height: 100.0)
    }
    
    
}
