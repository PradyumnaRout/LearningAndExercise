//
//  Device+CoreDataProperties.swift
//  LearningAndExercise
//
//  Created by hb on 10/11/25.
//
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }

    @NSManaged public var detailData: Data?
    @NSManaged public var id: String?
    @NSManaged public var name: String?

}

extension Device {
    
    var detail: DeviceData? {
        get {
            guard let data = detailData else { return nil }
            // You can manage error by replacing try? with do-try-catch block.
            return try? JSONDecoder().decode(DeviceData.self, from: data)
        } set {
            detailData = try?JSONEncoder().encode(newValue)
        }
    }
}

extension Device : Identifiable {

}
