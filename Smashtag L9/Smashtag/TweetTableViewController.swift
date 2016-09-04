//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class TweetTableViewController: UITableViewController, UITextFieldDelegate
{
    // MARK: Model
    
    var managedObjectContext : NSManagedObjectContext? = (
    UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext

    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            tweets.removeAll()
            lastTwitterRequest = nil
            searchForTweets()
            title = searchText
        }
    }
    
    // MARK: Fetching Tweets
    
    private var twitterRequest: Twitter.Request? {
        if lastTwitterRequest == nil {
            if let query = searchText where !query.isEmpty {
                return Twitter.Request(search: query + " -filter:retweets", count: 100)
            }
        }
        return lastTwitterRequest?.requestForNewer
    }
    
    private var lastTwitterRequest: Twitter.Request?

    private func searchForTweets()
    {
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets { [weak weakSelf = self] newTweets in
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, atIndex: 0)
                            weakSelf?.updateDatabase(newTweets)
                        }
                    }
                    weakSelf?.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    private func updateDatabase(newTweets: [Twitter.Tweet]){
        managedObjectContext?.performBlock {
            for twitterInfo in newTweets{
                _ = Tweet.tweetWithTweeterInfo(twitterInfo, inManagedObjectContext: self.managedObjectContext!)
            }
            do {
                try self.managedObjectContext!.save()
            }
            catch let error {
                print("Core Data Error: \(error )")
            }
        }
        printDatabaseStatistics()
        print("done print database statistics")
    }
    
    private func printDatabaseStatistics(){
        managedObjectContext?.performBlock{
            if let results = try? self.managedObjectContext!.executeFetchRequest(NSFetchRequest(entityName: "TwitterUser")) {
                print("\(results.count) TwitterUsers")
            }
            
            let tweetCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "Tweet"), error: nil)
            print("\(tweetCount) Tweets")
        }
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        searchForTweets()
    }
    
    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tweets.count - section)"
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetCellIdentifier, forIndexPath: indexPath)

        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
    
        return cell
    }
    
    // MARK: Constants
    
    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
    }
    
    // MARK: Outlets

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }
    
    // MARK: View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "TweetersMentioningSearchTerm" {
            if let tweetersTVC = segue.destinationViewController as? TweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.managedObjectContext = managedObjectContext
            }
        }
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    var fetchedResultsController : NSFetchedResultsController?
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let request = NSFetchRequest(entityName: "Tweet")
//            request.sortDescriptors = [NSSortDescriptor(
//                key: "created",
//                ascending: false,
//                selector: nil)]
//            fetchedResultsController = NSFetchedResultsController(
//                fetchRequest: request,
//                managedObjectContext: managedObjectContext!,
//                sectionNameKeyPath: "created", //nil
//                cacheName: nil)
//            if let tweet = fetchedResultsController?.objectAtIndexPath(indexPath) as? Tweet{
//                managedObjectContext?.deleteObject(tweet)
//                print("tweet: \(tweet)")
//            }
            request.predicate = NSPredicate(format: "unique = %@", tweets[indexPath.section][indexPath.row].id)
            if let tweet = (try? managedObjectContext!.executeFetchRequest(request))?.first as? Tweet {
                managedObjectContext?.deleteObject(tweet)
            }
            
            tweets[indexPath.section].removeAtIndex(indexPath.row)
            printDatabaseStatistics()
        }
    }
}
