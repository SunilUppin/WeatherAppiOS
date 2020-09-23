//
//  HourlyData+CoreDataProperties.swift
//  EnParadigmWeatherApp
//
//  Created by Sunil on 23/09/20.
//  Copyright © 2020 User. All rights reserved.
//
//

import Foundation
import CoreData


extension HourlyData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HourlyData> {
        return NSFetchRequest<HourlyData>(entityName: "HourlyData")
    }

    @NSManaged public var timeValue: String?
    @NSManaged public var temperatureValue: String?

}
