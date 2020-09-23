//
//  Location+CoreDataProperties.swift
//  EnParadigmWeatherApp
//
//  Created by Sunil on 23/09/20.
//  Copyright © 2020 User. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var weatherInfo: NSObject?
    @NSManaged public var locationName: String?
    @NSManaged public var locationId: String?

}
