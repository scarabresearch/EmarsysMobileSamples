//
//  RecommendationManager.swift
//  EmarsysMobileShopSwift
//
//

import UIKit

protocol RecommendationManagerDelegate {
    func updateWithItem(item: Item)
}

class RecommendationManager: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var recommendResults = [Item]()
    var delegate: RecommendationManagerDelegate? = nil
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendResults.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("RecommendedItemCell", forIndexPath: indexPath) as! RecommendedItem
        let item = recommendResults[indexPath.row]
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let delegate = delegate else { return }
        delegate.updateWithItem(recommendResults[indexPath.row])
    }
}
