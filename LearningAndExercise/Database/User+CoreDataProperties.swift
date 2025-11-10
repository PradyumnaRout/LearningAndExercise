//
//  User+CoreDataProperties.swift
//  LearningAndExercise
//
//  Created by hb on 10/11/25.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var age: Int32
    @NSManaged public var email: String?
    @NSManaged public var familyName: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: String?
    @NSManaged public var place: String?
    @NSManaged public var profilePic: String?

}

extension User : Identifiable {

}
