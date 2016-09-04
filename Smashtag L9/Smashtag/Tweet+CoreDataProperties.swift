//
//  Tweet+CoreDataProperties.swift
//  Smashtag
//
//  Created by Ivan on 31.08.16.
//  Copyright © 2016 Stanford University. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Tweet {

    @NSManaged var text: String?
    @NSManaged var unique: String?
    @NSManaged var created: NSDate?
    @NSManaged var tweeter: NSManagedObject?

}
