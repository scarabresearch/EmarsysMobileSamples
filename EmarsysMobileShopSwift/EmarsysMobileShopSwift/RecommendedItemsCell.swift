//
//  RecommendedItemsCell.swift
//  EmarsysMobileShopSwift
//

import UIKit

class RecommendedItemsCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var recommendedCollectionView: UICollectionView!
    
    var items = [Item]()
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemCell", forIndexPath:indexPath) as! RecommendedItem
        
        // Configure the cell
        let item = items[indexPath.row]
        
        cell.title.text = item.title
        cell.item = item
        
        let url = NSURL(string: item.image!)
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(url!, completionHandler: {(data, response, error) in
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { return }
            dispatch_async(dispatch_get_main_queue()) {
                guard let cell = collectionView.cellForItemAtIndexPath(indexPath) else {
                    NSLog("Failed to get cell for index path %@", indexPath)
                    return
                }
                let updateCell = cell as! RecommendedItem
                updateCell.image.image = image
            }
        }).resume()
        
        return cell
    }
}
