//
//  ItemsManager.swift
//  EmarsysPredictShopSwift
//
//

import UIKit

class ItemsManager: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var items = [Item]()
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, numberOfSectionsInTableView section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell")
        
        let item = items[indexPath.row]
        
        let title = cell?.contentView.viewWithTag(11) as! UILabel
        title.text = item.title
        
        let price = cell?.contentView.viewWithTag(12) as! UILabel
        price.text = String(format: "$%.02f", item.price!)
        
        let url = NSURL(string: item.image!)
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(url!, completionHandler: {(data, response, error) in
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { return }
            dispatch_async(dispatch_get_main_queue()) {
                guard let updateCell = tableView.cellForRowAtIndexPath(indexPath) else {
                    NSLog("Failed to get cell for index path %@", indexPath)
                    return
                }
                let imageView = updateCell.contentView.viewWithTag(13) as! UIImageView
                imageView.image = image
            }
        }).resume()
        
        return cell!
    }
}
