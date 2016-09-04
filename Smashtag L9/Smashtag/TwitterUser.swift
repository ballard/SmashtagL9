//
//  TwitterUser.swift
//  Smashtag
//
//  Created by Ivan on 31.08.16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class TwitterUser: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    class func twitterUserWithTwitterInfo(twitterInfo: Twitter.User, inManagedObjectContext context: NSManagedObjectContext) -> TwitterUser? {
        
        let request = NSFetchRequest(entityName: "TwitterUser")
        request.predicate = NSPredicate(format: "screenName = %@", twitterInfo.screenName)
        
        if let twitterUser = (try? context.executeFetchRequest(request))?.first as? TwitterUser {
            var tweetsCount = Int(twitterUser.tweetsCount!)
            tweetsCount += 1
            twitterUser.tweetsCount! = tweetsCount
            return twitterUser
        } else {
            if let twitterUser = NSEntityDescription.insertNewObjectForEntityForName("TwitterUser", inManagedObjectContext: context) as? TwitterUser{
                twitterUser.name = twitterInfo.name
                twitterUser.screenName = twitterInfo.screenName
                twitterUser.tweetsCount = 1
                return twitterUser
            }
        }
        
        return nil
        
    }
}
