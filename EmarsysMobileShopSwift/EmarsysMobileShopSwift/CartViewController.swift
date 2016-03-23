//
//  CartViewController.swift
//  EmarsysMobileShopSwift
//
//

import UIKit
import EmarsysMobile

class CartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var buyButton: UIBarButtonItem!
    @IBOutlet weak var cartItemsTableView: UITableView!
    @IBOutlet weak var recommendedCollectionView: UICollectionView!
    
    var recommendResults = [Item]()
    
    @IBAction func buy(sender: UIBarButtonItem) {
        let transaction = EMTransaction()
        let cartItems = Cart.sharedCart.convertItems()
        transaction.setCart(cartItems)
        
        let orderID = NSUUID().UUIDString
        transaction.setPurchase(orderID, ofItems: cartItems)
        
        let emarsysSession = EMSession.sharedSession()
        emarsysSession.sendTransaction(transaction, errorHandler: {(error) in
            // Some error happened
            NSLog("value: %@", error)
            return
        })
        
        Cart.sharedCart.cartItems.removeAll()
        cartItemsTableView .reloadData()
        sendRecommend()
        
        let alert = UIAlertController(title: "Buy was successful.", message: nil, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action) in })
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(cartItemsTableView, selector: "reloadData", name: "CartChanged", object: nil)
        
        recommendResults = [Item]()
        cartItemsTableView.dataSource = self
        cartItemsTableView.delegate = self
        recommendedCollectionView.dataSource = self
        recommendedCollectionView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        sendRecommend()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = Cart.sharedCart.cartItems.count
        buyButton.enabled = count != 0
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CartItemCell") as! CartItemCell
        
        if indexPath.row < Cart.sharedCart.cartItems.count {
            let cartItem = Cart.sharedCart.cartItems[indexPath.row]
            
            cell.title.text = cartItem.item.title
            cell.count.text = String(format: "%d", cartItem.count)
            
            let url = NSURL(string: cartItem.item.image!)
            let session = NSURLSession.sharedSession()
            
            session.dataTaskWithURL(url!, completionHandler: {(data, response, error) in
                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                dispatch_async(dispatch_get_main_queue()) {
                    if let updateCell = tableView.cellForRowAtIndexPath(indexPath) {
                        let cartItemCell = updateCell as! CartItemCell
                        cartItemCell.itemImage.image = image
                    }
                }
            }).resume()
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CartShowItem" {
            let ctr = segue.destinationViewController as! ItemDetailViewController
            ctr.item = Cart.sharedCart.cartItems[cartItemsTableView.indexPathForSelectedRow!.row].item
        } else if segue.identifier == "CartShowRecommendedItem" {
            let ctr = segue.destinationViewController as! ItemDetailViewController
            let recommendedItem = sender as! RecommendedItem
            ctr.item = recommendedItem.item
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()
        Cart.sharedCart.cartItems.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        tableView.endUpdates()
        
        sendRecommend()
        
        let alert = UIAlertController(title: "Remove from cart was successful.", message: nil, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action) in })
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendResults.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemCell", forIndexPath: indexPath) as! RecommendedItem
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
    
    func sendRecommend() {
        let emarsysSession = EMSession.sharedSession()
        let transaction = EMTransaction()
        let cartItems = Cart.sharedCart.convertItems()
        transaction.setCart(cartItems)
        
        let recommend = EMRecommendationRequest(logic: "CART")
        
        recommend.limit = 10
        recommend.completionHandler = {result in
            // Process result
            for obj in result.products {
                let item = Item(withItem: obj)
                self.recommendResults.append(item)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.recommendedCollectionView.reloadData()
            }
        }
        
        transaction.recommend(recommend)
        
        // Firing the transaction. Should be the last call on the page, called only once.
        emarsysSession.sendTransaction(transaction, errorHandler: {(error) in
            // Some error happened
            NSLog("value: %@", error)
            return
        })
    }
}
