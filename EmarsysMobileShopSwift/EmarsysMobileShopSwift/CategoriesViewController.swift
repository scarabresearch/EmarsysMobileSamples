//
//  CategoriesViewController.swift
//  EmarsysMobileShopSwift
//
//

import UIKit
import EmarsysMobile

class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var recommendedTableView: UITableView!
    
    var category: String = ""
    var items = [Item]()
    var recommendResults = [Item]()
    var categories = [String]()
    var shopTopics = [String]()
    var itemsWithTopics = [String:[Item]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        recommendedTableView.delegate = self
        recommendedTableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        shopTopics = DataSource.sharedDataSource.categories
        sendRecommend()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == categoriesTableView {
            return ""
        } else if section < categories.count {
            var category = categories[section]
            let needle = "Root Catalog>"
            if let range = category.rangeOfString(needle) {
                let idx = range.endIndex
                category = category.substringFromIndex(idx)
            }
            return category
        } else {
            return ""
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == categoriesTableView {
            return 1
        }
        return categories.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == categoriesTableView {
            return shopTopics.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == categoriesTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell")
            let label = shopTopics[indexPath.row] as String
            cell!.textLabel?.text = label
            return cell!
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("RecommendedItemCell") as! RecommendedItemsCell
            
            if indexPath.section <= categories.count - 1 {
                let category = categories[indexPath.section]
                let categoryItems = itemsWithTopics[category]
                cell.items = categoryItems ?? [Item]()
                cell.recommendedCollectionView.dataSource = cell
                cell.recommendedCollectionView.delegate = cell
                cell.recommendedCollectionView.reloadData()
            }
            
            return cell
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCategory" {
            let ctr = segue.destinationViewController as! CategoryViewController
            ctr.category = shopTopics[categoriesTableView.indexPathForSelectedRow!.row]
        } else if segue.identifier == "ShowSelectedRecItem" {
            let ctr = segue.destinationViewController as! ItemDetailViewController
            let recommendedItem = sender as! RecommendedItem
            ctr.item = recommendedItem.item
        }
    }
    
    //TOPICAL
    func sendRecommend() {
        let emarsysSession = EMSession.sharedSession()
        let transaction = EMTransaction()
        let cartItems = Cart.sharedCart.convertItems()
        transaction.setCart(cartItems)
        
        recommendResults.removeAll()
        itemsWithTopics.removeAll()
        categories.removeAll()
        
        for index in 0...10 {
            let logic = NSString(format:"%@%i", "HOME_", index) as String
            let recommend = EMRecommendationRequest(logic: logic)
            recommend.limit = 10
            recommend.completionHandler = {result in
                defer {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.recommendedTableView.reloadData()
                    }
                }
                guard let topic = result.topic else { return }
                
                // Process result
                if !topic.isEmpty {
                    if !self.categories.contains(topic) {
                        self.categories.append(topic)
                    }
                    
                    if self.itemsWithTopics[topic] == nil {
                        let newItemCategory = [Item]()
                        self.itemsWithTopics[topic] = newItemCategory
                    }
                    
                    for obj in result.products {
                        let item = Item(withItem: obj)
                        self.recommendResults.append(item)
                        self.itemsWithTopics[topic]?.append(item)
                    }
                }
            }
            transaction.recommend(recommend)
        }
        
        // Firing the EmarsysMobile queue. Should be the last call on the page, called only once.
        emarsysSession.sendTransaction(transaction, errorHandler: {error in
            // Some error happened
            NSLog("value: %@", error)
            return
        })
    }
    
}
