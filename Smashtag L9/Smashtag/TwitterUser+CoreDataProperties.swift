//
//  TwitterUser+CoreDataProperties.swift
//  Smashtag
//
//  Created by Ivan on 02.09.16.
//  Copyright © 2016 Stanford University. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TwitterUser {

    @NSManaged var name: String?
    @NSManaged var screenName: String?
    @NSManaged var tweetsCount: NSNumber?
    @NSManaged var tweet: NSSet?

}
