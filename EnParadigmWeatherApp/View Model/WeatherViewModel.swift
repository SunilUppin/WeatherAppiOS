//
//  WeatherViewModel.swift
//  EnParadigmWeatherApp
//
//  Created by Sunil on 22/09/20.
//  Copyright © 2020 User. All rights reserved.
//

import Foundation

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
    
    func getWeatherDetails(cityName: String, _ completion: @escaping (_ e: NSError?) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://api.openweathermap.org/data/2.5/forecast?q=bengaluru&appid=\(appId)")!,timeoutInterval: Double.infinity)
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
            do {
                if let det = try? JSONDecoder().decode(Details.self, from: jsonData) {
                    print(det)
                    self.details = det
                    var tempArray : [String] = []
                    var curDate = ""
                    for i in 0..<det.list.count {
                        if i == 0 {
                            curDate = det.list[i].dtTxt?.components(separatedBy: " ").first ?? ""
                            
                        } else {
                            if !(det.list[i].dtTxt?.contains(curDate) ?? false) {
                                curDate = det.list[i].dtTxt?.components(separatedBy: " ").first ?? ""
                                tempArray.append(curDate )
                            }
                        }
                    }
                    
                    self.daysToDisplay = tempArray
                    self.daysArray = det.list
                    self.getNextDaysTemperature()
                    self.getImageSet()
                    self.getHourlyDataForToday()
                    completion(nil)
                } else {
                    print("No location found")
                    completion(nil)
                }
            } catch {
                
            }
        })
        task.resume()
    }
    
    //    import Foundation
    
    
//    func getData() {
//        var semaphore = DispatchSemaphore (value: 0)
//
//        var request = URLRequest(url: URL(string: "https://api.openweathermap.org/data/2.5/forecast?q=bengaluru&appid=7b1b2ec6a4439c294a72c98905d6769c")!,timeoutInterval: Double.infinity)
//        request.httpMethod = "GET"
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data else {
//                print(String(describing: error))
//                return
//            }
//            let temp = String(data: data, encoding: .utf8)!
//            do {
//                let det = try JSONDecoder().decode(Details.self, from: data)
//                print(det)
//            } catch {
//
//            }
//
//            print(temp)
//            semaphore.signal()
//        }
//
//        task.resume()
//        semaphore.wait()
//    }
    
    func measureConverter(temperatute: Double) -> String {
//        let temperatute = daysArray?[0].main?.temp ?? 0.0
        let measureFormatter = MeasurementFormatter()
        let measurement = Measurement(value: temperatute - 273.15, unit: UnitTemperature.celsius)
        let output = measureFormatter.string(from: measurement)
        return output
    }
    
//    func convertStringDateToDays(strDate: String){
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd" //Your date format
//        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
//        //according to date format your date string
//        guard let date = dateFormatter.date(from: strDate) else {
//            fatalError()
//        }
//        print(date)
//
////        let formatter  = DateFormatter()
////        formatter.dateFormat = "yyyy-MM-dd"
//        guard let todayDate = dateFormatter.date(from: strDate) else { return }
//        let myCalendar = Calendar(identifier: .gregorian)
//        let weekDay = myCalendar.component(.weekday, from: todayDate)
//    }
    
    func getNextDaysTemperature() {
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
}
