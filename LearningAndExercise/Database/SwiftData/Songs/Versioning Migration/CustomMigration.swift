//
//  CustomMigration.swift
//  LearningAndExercise
//
//  Created by hb on 16/01/26.
//

import Foundation
import SwiftData

enum LightWightMigrationPlan: SchemaMigrationPlan {

    static var schemas: [any VersionedSchema.Type] {
        // v1 tpo v2 Migration (Rename)
//        [MySchemaV1.self, MySchemaV2.self]
        
        // v2 to v3 Migration(New Attribute)
//        [MySchemaV1.self, MySchemaV2.self, MySchemaV3.self]
        
        // v3 to v4 Migration (new Attribute / data replacement)
//        [MySchemaV1.self, MySchemaV2.self, MySchemaV3.self, MySchemaV4.self]
        
        // v4 to v5 migration (delete previous attribute)
        [MySchemaV1.self, MySchemaV2.self, MySchemaV3.self, MySchemaV4.self, MySchemaV5.self]
        
//        [MySchemaV1.self, MySchemaV4.self]
    }

    static var stages: [MigrationStage] {
        [
            migrateV1toV2,
            migrateV2toV3,
            migrateV3toV4,
            migrateV4toV5
            
//            migrateV1toV4
        ]
    }

    //MARK: First Light Weight Migration Through Versioning
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: MySchemaV1.self,
        toVersion: MySchemaV2.self
    )
    
    static let migrateV2toV3 = MigrationStage.custom(
        fromVersion: MySchemaV2.self,
        toVersion: MySchemaV3.self,
        willMigrate: nil) { context in
            let items = try? context.fetch(FetchDescriptor<MySchemaV3.Song>())
            
            items?.forEach { item in
                item.singer = "Not Found"
            }
            try? context.save()
        }
    
    static let migrateV3toV4 = MigrationStage.custom(
        fromVersion: MySchemaV3.self,
        toVersion: MySchemaV4.self,
        willMigrate: nil
    ) { context in

        let items = try? context.fetch(FetchDescriptor<MySchemaV4.Song>())
        
        items?.forEach { item in
            let runtimeFloat = Float(item.runTime) ?? 0.0
            item.runTimeInFloat = runtimeFloat
        }
        try? context.save()
    }
    
    static let migrateV4toV5 = MigrationStage.lightweight(
        fromVersion: MySchemaV4.self,
        toVersion: MySchemaV5.self
    )
    
    
    
    
    
    
    
    
    static let migrateV1toV4 = MigrationStage.custom(
        fromVersion: MySchemaV1.self,
        toVersion: MySchemaV4.self,
        willMigrate: nil
    ) { context in

        let items = try? context.fetch(FetchDescriptor<MySchemaV4.Song>())
        
        items?.forEach { item in
            let runtimeFloat = Float(item.runTime) ?? 0.0
            item.runTimeInFloat = runtimeFloat
        }
        try? context.save()
    }
}

