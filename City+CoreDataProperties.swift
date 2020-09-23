//
//  City+CoreDataProperties.swift
//  EnParadigmWeatherApp
//
//  Created by Sunil on 23/09/20.
//  Copyright © 2020 User. All rights reserved.
//
//

import Foundation
import CoreData


extension City {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: "City")
    }

    @NSManaged public var cityName: String?
    @NSManaged public var cityTemp: String?
    @NSManaged public var weatherType: String?
    @NSManaged public var humidity: String?
    @NSManaged public var pressure: String?
    @NSManaged public var windSpeed: String?
    @NSManaged public var windDegree: String?
    @NSManaged public var desc: String?
    @NSManaged public var visibility: String?

}
