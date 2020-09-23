//
//  HomeVC.swift
//  EnParadigmWeatherApp
//
//  Created by Sunil on 22/09/20.
//  Copyright © 2020 User. All rights reserved.
//

import UIKit
import CoreLocation

class HomeVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var viewModel = WeatherViewModel()
    var locationName: String?
    
    let locationManager = CLLocationManager()
    var latitude : Double?
    var longitude : Double?
    
    var otherDetailsArray = ["Humidity", "Pressure", "Wind Speed", "Visibility", "Description", "Wind Degree"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = UIImageView(image: UIImage(named: "daytimeClear"))
        registerNibs()
        tableView.tableFooterView = UIView()
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func registerNibs() {
        tableView.register(UINib(nibName: "LocationName", bundle: nil), forCellReuseIdentifier: "LocationNameCell")
        tableView.register(UINib(nibName: "NextDaysWeatherInfo", bundle: nil), forCellReuseIdentifier: "NextDaysWeatherInfoCell")
        tableView.register(UINib(nibName: "OtherDetailsCell", bundle: nil), forCellReuseIdentifier: "OtherDetailsCell")
        tableView.register(UINib(nibName: "PresentDayTableCell", bundle: nil), forCellReuseIdentifier: "PresentDayTableCell")
    }
    
    func getWeatherDetails() {
        locationName = "Bengaluru"
        viewModel.getWeatherDetails(cityName: locationName ?? "") { (error) in
            guard error == nil else {
                return
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        latitude = location.latitude
        longitude = location.longitude
        if let lat = latitude, let long = longitude {
            getCurrenrtLocation(lat: lat, long: long)
        }
    }
    
    func getCurrenrtLocation(lat: Double, long: Double) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: lat, longitude: long)

        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in

            placemarks?.forEach { (placemark) in

                if let city = placemark.locality {
                    print(city)
                    self.viewModel.getWeatherDetails(cityName: city) { (error) in
                        if self.viewModel.noLocFound {
                            // Show alert
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Alert!", message: "Location not found.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        })
    }

}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 300.0
            
        case 1:
            return 150.0
            
        case 2...6:
            return 50.0
            
        default:
            return 100.0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (viewModel.daysToDisplay?.count ?? 0) + 3 + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let count = viewModel.daysToDisplay?.count ?? 0
        guard count > 0 else {
            return UITableViewCell()
        }
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationNameCell", for: indexPath) as! LocationNameCell
            cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.locationNameLabel.text = viewModel.details?.city?.name
            cell.weatherLabel.text = viewModel.daysArray?[indexPath.row].weather?[indexPath.row].weatherDescription
            cell.temperatureLabel.text = viewModel.measureConverter(temperatute: viewModel.daysArray?[indexPath.row].main?.temp ?? 0.0)
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PresentDayTableCell", for: indexPath) as! PresentDayTableCell
            cell.viewModel = self.viewModel
            cell.collectionView.reloadData()
            return cell
        }
        else if indexPath.row <= count + 1 {

            let cell = tableView.dequeueReusableCell(withIdentifier: "NextDaysWeatherInfoCell", for: indexPath) as! NextDaysWeatherInfoCell
            let index = indexPath.row - 2
            cell.seperatorView.isHidden = true
            cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.dayLabel.text = viewModel.daysToDisplay?[index]
            cell.tempLabel.text = viewModel.nextDaysTemperatureArray[index]
            if viewModel.weatherArray[index].lowercased().contains("clouds") {
                cell.imgView?.image = UIImage(named: "dayCloudy")
            } else {
                cell.imgView?.image = UIImage(named: "rainy")
            }
            if indexPath.row == count + 1 {
                cell.seperatorView.isHidden = false
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherDetailsCell", for: indexPath) as! OtherDetailsCell
            let index = indexPath.row - 7
            cell.layer.backgroundColor = UIColor.clear.cgColor
            switch index {
            case 0:
                cell.leftTitle.text = otherDetailsArray[index]
                cell.rightTitle.text = otherDetailsArray[index + 1]
                cell.leftValue.text = "\(viewModel.daysArray?[0].main?.humidity ?? 0)" + "%"
                cell.rightValue.text = "\(viewModel.daysArray?[0].main?.pressure ?? 0)" + " hPa"
                
            case 1:
                cell.leftTitle.text = otherDetailsArray[index + 1]
                cell.rightTitle.text = otherDetailsArray[index + 2]
                cell.leftValue.text = "\(viewModel.daysArray?[0].wind?.speed ?? 0.0)" + " km/h"
                let visibility = (viewModel.daysArray?[0].visibility ?? 0) / 1000
                cell.rightValue.text = "\(visibility) km"
                
            case 2:
                cell.leftTitle.text = otherDetailsArray[index + 2]
                cell.rightTitle.text = otherDetailsArray[index + 3]
                cell.leftValue.text = "\(viewModel.daysArray?[0].weather?[0].weatherDescription ?? "")"
                cell.rightValue.text = "\(viewModel.daysArray?[0].wind?.deg ?? 0)"
                
            default:
                break
            }
            return  cell
        }
        
    }
}
