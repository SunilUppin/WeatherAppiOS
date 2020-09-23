//
//  WeatherViewModel.swift
//  EnParadigmWeatherApp
//
//  Created by Sunil on 22/09/20.
//  Copyright © 2020 User. All rights reserved.
//

import Foundation
import CoreData

class WeatherViewModel {
    
    let appId = "7b1b2ec6a4439c294a72c98905d6769c"
    let session = URLSession.shared

    var noLocFound = false
    var daysArray: [List]?
    var daysToDisplay : [String]?
    var details: Details?
    var nextDaysTemperatureArray: [String] = []
    var weatherArray: [String] = []
    
    var hourlyArray: [String] = []
    var hourlyTempArray: [String] = []
    var hourlyImageData: [String] = []
    
    var cityObj: City?
    
    var cityArray: [String] = []
    var cityTempArray: [String] = []
    var cityName = ""
    
    func getWeatherDetails(cityName: String, _ completion: @escaping (_ e: NSError?) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://api.openweathermap.org/data/2.5/forecast?q=\(cityName)&appid=\(appId)")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            let jsonData = data ?? Data()
            print("Data ===> \(String(describing: jsonData))")
            print("Response ===> \(String(describing: response))")
            print("Error ===> \(String(describing: error))")
            
            guard error == nil else {
                if error?.localizedDescription.contains("offline") ?? false {
                    print("No Internet")
                }
                print("===ERROR===")
                return
            }
            
            self.deleteObject()
            
            do {
                if let det = try? JSONDecoder().decode(Details.self, from: jsonData) {
                    print(det)
                    self.details = det
                    var tempArray : [String] = []
                    var curDate = ""
                    for i in 0..<det.list.count {
                        if i == 0 {
                            curDate = det.list[i].dtTxt?.components(separatedBy: " ").first ?? ""
                            self.cityTempArray.append("\(det.list[i].main?.temp ?? 0.0)")
                        } else {
                            if !(det.list[i].dtTxt?.contains(curDate) ?? false) {
                                curDate = det.list[i].dtTxt?.components(separatedBy: " ").first ?? ""
                                tempArray.append(curDate)
                            }
                        }
                    }
                    
                    self.cityArray.append(det.city?.name ?? "")
                    self.daysToDisplay = tempArray
                    self.daysArray = det.list
                    self.cityObj = det.city
                    self.saveToDB(arr: self.daysArray, city: self.cityObj)
                    
                    self.getNextDaysTemperature()
                    self.getImageSet()
                    self.getHourlyDataForToday()
                    completion(nil)
                } else {
                    print("No location found")
                    self.noLocFound = true
                    completion(nil)
                }
            } catch {
                
            }
        })
        task.resume()
    }
    
    func measureConverter(temperatute: Double) -> String {
        let measureFormatter = MeasurementFormatter()
        let measurement = Measurement(value: temperatute - 273.15, unit: UnitTemperature.celsius)
        let output = measureFormatter.string(from: measurement)
        return output
    }
    
    func getNextDaysTemperature() {
        self.nextDaysTemperatureArray = []
        var flag = false
        for str in daysToDisplay! {
            flag = true
            let count = daysArray?.count ?? 0
            for i in 0..<count {
                if flag == true, daysArray?[i].dtTxt?.contains(str) ?? false {
                    flag = false
                    let min = measureConverter(temperatute: daysArray?[i].main?.tempMin ?? 0.0)
                    let max = measureConverter(temperatute: daysArray?[i].main?.tempMax ?? 0.0)
                    let final = "\(min) / \(max)"
                    self.nextDaysTemperatureArray.append(final)
                }
            }
        }
    }
    
    func getImageSet() {
        self.weatherArray = []
        var flag = false
        for str in daysToDisplay! {
            flag = true
            let count = daysArray?.count ?? 0
            for i in 0..<count {
                if flag == true, daysArray?[i].dtTxt?.contains(str) ?? false {
                    flag = false
                    let temp = daysArray?[i].weather?[0].main ?? ""
                    weatherArray.append(temp)
                }
            }
        }
    }
    
    func getHourlyDataForToday() {
        self.hourlyArray = []
        self.hourlyImageData = []
        self.hourlyTempArray = []
        let count = daysArray?.count ?? 0
        let todaysDate = daysArray?.first?.dtTxt?.components(separatedBy: " ").first ?? ""
        for i in 0..<count {
            if (daysArray?[i].dtTxt?.contains(todaysDate))! {
                let temp = daysArray?[i].main?.temp ?? 0.0
                let finalTemp = measureConverter(temperatute: temp)
                hourlyTempArray.append(finalTemp)
                
                let date = daysArray?[i].dtTxt?.components(separatedBy: " ")
                let time = date?[1].dropLast(3) ?? ""
                let strTime = "\(String(describing: time))"
                hourlyArray.append(strTime)
                
                let weather = daysArray?[i].weather?[0].main ?? ""
                hourlyImageData.append(weather)
            } else {
                return
            }
        }
    }
    
    
//    private func createHourlyEntityFrom(hourlyArr: [String], hourlyTempArr: [String]) {
//
//        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
//        let hourlyEntity = NSEntityDescription.insertNewObject(forEntityName: "HourlyData", into: context) as? HourlyData
//
//        if hourlyArr.count == hourlyTempArr.count {
//            do {
//                let horlyData = try? NSKeyedArchiver.archivedData(withRootObject: hourlyArr, requiringSecureCoding: false)
//                hourlyEntity?.setValue(horlyData, forKey: "timeValue")
//                try context.save()
//            } catch let error {
//                print(error)
//            }
//        }
//    }
    
    func saveToDB(arr: [List]?, city: City?) {
        do {
            guard let list = arr, let cityObj = city else {
                return
            }
            let data1 = try PropertyListEncoder().encode(list)
            let locationEntity = Location.createEntity(cityId: "\(cityObj.id)")
            locationEntity?.locationName = cityObj.name
            locationEntity?.locationId = "\(cityObj.id)"
            locationEntity?.weatherInfo = data1 as NSObject?
            
            let moc = CoreDataStack.sharedInstance.persistentContainer.viewContext
            try moc.save()
            
        } catch {
            
        }
    }
    
    func fetchFromDB(index: Int? = nil) {
        
        let city = Location.fetchCity()
            
        let tmp = city?[index ?? 0]
        self.cityName = tmp?.locationName ?? ""
        do {
            let res = try PropertyListDecoder().decode(Array<List>.self, from: tmp?.weatherInfo as! Data)
            
            getNextSetOfDays(arr: res)
            print(res)
        } catch {
            print("Error fetching")
        }
        print(city as Any)
    }
    
    func getNextSetOfDays(arr: [List]) {
        self.daysArray = arr
        var tempArray : [String] = []
        var curDate = ""
        for i in 0..<arr.count {
            if i == 0 {
                curDate = arr[i].dtTxt?.components(separatedBy: " ").first ?? ""
                self.cityTempArray.append("\(arr[i].main?.temp ?? 0.0)")
            } else {
                if !(arr[i].dtTxt?.contains(curDate) ?? false) {
                    curDate = arr[i].dtTxt?.components(separatedBy: " ").first ?? ""
                    tempArray.append(curDate)
                }
            }
        }
        self.daysToDisplay = tempArray
        self.getNextDaysTemperature()
        self.getHourlyDataForToday()
        self.getImageSet()
    }
    
    
    func deleteObject() {
        do {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]

            for item in items {
                context.delete(item)
            }
            try context.save()
        } catch {
            
        }
    }
    
    func dateFormatter(strDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: strDate)

        dateFormatter.dateFormat = "dd-MMM-yyyy"
        return dateFormatter.string(from: date!)
    }
}


