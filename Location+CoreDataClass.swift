//
//  Location+CoreDataClass.swift
//  EnParadigmWeatherApp
//
//  Created by Sunil on 23/09/20.
//  Copyright © 2020 User. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(Location)
public class Location: NSManagedObject {
    
    static func createEntity(cityId id: String?) -> Location? {
        guard let cityId = id, let location = isCityExist(cityID: cityId) else {
            
            let moc = CoreDataStack.sharedInstance.persistentContainer.viewContext
            
            if let entityDescription = NSEntityDescription.entity(forEntityName: "Location", in: moc) {
                return NSManagedObject(entity: entityDescription, insertInto: moc) as? Location
            }
            return nil
        }
        return location
    }
    
    static func isCityExist(cityID id: String) -> Location? {
        let predicate = NSPredicate(format: "locationId == %@", id)
        let moc = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        fetchReq.predicate = predicate
        
        do {
            if let res = try? moc.fetch(fetchReq) as? [Location]{
                return (res.count > 0) ? res.first : nil
            }
        }
        return nil
    }
    
    static func fetchCity(withPredicate predicate: NSPredicate? = nil) -> [Location]? {
        let moc = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        fetchReq.predicate = predicate
        do {
            if let res = try? moc.fetch(fetchReq) as? [Location]{
                return (res.count > 0) ? res : nil
            }
        }
        return nil
    }
}
