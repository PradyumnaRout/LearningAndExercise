//
//  MigrationEntityMigrationPolicy.swift
//  LearningAndExercise
//
//  Created by hb on 10/11/25.
//

import Foundation
import CoreData

class MigrationEntityMigrationPolicy: NSEntityMigrationPolicy {
    // override method createDestinationInstance
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        if (sInstance.entity.name == "User") {
            
            let id = sInstance.value(forKey: "id") as? String
            let age = sInstance.value(forKey: "age") as? String
            let email = sInstance.value(forKey: "email") as? String
            let firstName = sInstance.value(forKey: "firstName") as? String
            let lastName = sInstance.value(forKey: "lastName") as? String
            let profilePic = sInstance.value(forKey: "profilePic") as? String
            
            
            let newUserEntity = NSEntityDescription.insertNewObject(forEntityName: "User", into: manager.destinationContext)
            
            newUserEntity.setValue(id, forKey: "id")
            newUserEntity.setValue(Int32(age ?? "0"), forKey: "age")
            newUserEntity.setValue(email, forKey: "email")
            newUserEntity.setValue(profilePic, forKey: "profilePic")
            newUserEntity.setValue(firstName, forKey: "firstName")
            newUserEntity.setValue(lastName, forKey: "familyName")
        }
    }
}
