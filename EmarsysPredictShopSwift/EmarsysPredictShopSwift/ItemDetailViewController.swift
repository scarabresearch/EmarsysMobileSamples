//
//  ItemDetailViewController.swift
//  EmarsysPredictShopSwift
//
//

import UIKit
import EmarsysPredictSDK

class ItemDetailViewController: UIViewController, RecommendationManagerDelegate {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var availability: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var recommendedCollectionView: UICollectionView!
    
    var item: Item!
    var recommendationManager: RecommendationManager!
    
    @IBAction func addToCart(sender: UIButton) {
        Cart.sharedCart.addItem(item)
        NSNotificationCenter.defaultCenter().postNotificationName("CartChanged", object: nil)
        
        let alert = UIAlertController(title: "Item added to cart", message: nil, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action) in })
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
        
        sendRecommend()
    }
    
    func updateWithItem(item: Item) {
        self.item = item
        updateItem()
    }
    
    func updateItem() {
        name.text = item.title
        
        let available: String!
        let color: UIColor!
        
        if item.available ?? false {
            available = "IN STOCK"
            color = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
        } else {
            available = "OUT OF STOCK"
            color = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
        }
        
        availability.text = String(format: "Availability: %@", available)
        availability.textColor = color
        price.text = String(format: "$%.02f", item.price!)
        
        let url = NSURL(string: item.image!)
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(url!, completionHandler: {(data, response, error) in
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { return }
            dispatch_async(dispatch_get_main_queue()) {
                self.image.image = image
            }
        }).resume()
        
        sendRecommend()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recommendationManager = RecommendationManager()
        recommendationManager.delegate = self
        recommendedCollectionView.dataSource = recommendationManager
        recommendedCollectionView.delegate = recommendationManager
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateItem()
    }
    
    func sendRecommend() {
        recommendationManager.recommendResults.removeAll()
        self.recommendedCollectionView.reloadData()
        
        let emarsysSession = EMSession.sharedSession()
        let transaction = EMTransaction.init(item: item.srcItem)
        let cartItems = Cart.sharedCart.convertItems()
        transaction.setCart(cartItems)
        transaction.setView(item.itemID)
        
        var logic = "RELATED"
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let userLogic = defaults.objectForKey(UserDefaultsKeys.DetailLogic.rawValue) {
            logic = userLogic as! String
        }
        
        let recommend = EMRecommendationRequest(logic: logic)
        
        recommend.limit = 10
        recommend.completionHandler = {result in
            // Process result
            for obj in result.products {
                let item = Item(withItem: obj)
                self.recommendationManager.recommendResults.append(item)
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
