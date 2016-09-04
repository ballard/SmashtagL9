//
//  Tweet.swift
//  Smashtag
//
//  Created by Ivan on 31.08.16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class Tweet: NSManagedObject {
    
    class func tweetWithTweeterInfo(twitterInfo: Twitter.Tweet, inManagedObjectContext context: NSManagedObjectContext) -> Tweet? {
        
        let request = NSFetchRequest(entityName: "Tweet")
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.id)
        
        if let tweet = (try? context.executeFetchRequest(request))?.first as? Tweet {
            return tweet
        } else {
            if let tweet = NSEntityDescription.insertNewObjectForEntityForName("Tweet", inManagedObjectContext: context) as? Tweet{
                tweet.unique = twitterInfo.id
                tweet.text = twitterInfo.text
                tweet.created = twitterInfo.created
                let tweeter = TwitterUser.twitterUserWithTwitterInfo(twitterInfo.user, inManagedObjectContext: context)
                tweet.tweeter = tweeter
                return tweet
            }
        }
        
        return nil
    }
    
    override func prepareForDeletion() {
        if let tweeter = self.tweeter as? TwitterUser{
            var tweetsCount = Int(tweeter.tweetsCount!)
            tweetsCount -= 1
            tweeter.tweetsCount = tweetsCount
        }
    }

// Insert code here to add functionality to your managed object subclass

}
