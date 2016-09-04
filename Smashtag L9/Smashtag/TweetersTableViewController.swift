//
//  TweetersTableViewController.swift
//  Smashtag
//
//  Created by Ivan on 31.08.16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class TweetersTableViewController: CoreDataTableViewController {
    
    var mention : String? { didSet{ updateUI() } }
    var managedObjectContext : NSManagedObjectContext? { didSet{ updateUI() } }
    
    private func updateUI(){
        if let context = managedObjectContext where mention?.characters.count > 0 {
            let request = NSFetchRequest(entityName: "TwitterUser")
            request.predicate = NSPredicate(format: "any tweet.text contains[c] %@ and !screenName beginswith[c] %@", mention!, "doom")
            request.sortDescriptors = [
                NSSortDescriptor(
                    key: "tweetsCount",
                    ascending: false,
                    selector: nil),
                NSSortDescriptor(
                key : "screenName",
                ascending : true,
                selector : #selector(NSString.localizedCaseInsensitiveCompare(_:))
                ) ]
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil)
        } else {
            fetchedResultsController = nil
        }
    }
    
//    private func tweetCountWithMentionByTwitterUser(user: TwitterUser) -> Int?{
//        var count: Int?
//        user.managedObjectContext?.performBlockAndWait{
//            let request = NSFetchRequest(entityName: "Tweet")
//            request.predicate = NSPredicate(format: "text contains[c] %@ and tweeter = %@", self.mention!, user)
//            count = user.managedObjectContext?.countForFetchRequest(request, error: nil)
//        }
//        
//        return count
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TwitterUserCell", forIndexPath: indexPath)

        // Configure the cell...
        
        if let twitterUser = fetchedResultsController?.objectAtIndexPath(indexPath) as? TwitterUser {
            var screenName : String?
            var tweetsCount : Int?
            twitterUser.managedObjectContext?.performBlockAndWait{
                screenName = twitterUser.screenName
                tweetsCount = Int(twitterUser.tweetsCount!)
            }
//            print("tweets count: \(tweetsCount) by user: \(screenName)")
            cell.textLabel?.text = screenName
            cell.detailTextLabel?.text = (tweetsCount! == 1) ? "1 Tweet" : ("\(tweetsCount!) tweets")
            
//            if let count = tweetCountWithMentionByTwitterUser(twitterUser) {
//                cell.detailTextLabel?.text = (count == 1) ? "1 Tweet" : ("\(count) tweets")
//            } else {
//                cell.detailTextLabel?.text = ""
//            }
        }
        return cell
    }
    
    
}
