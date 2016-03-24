//
//  CategoryViewController.swift
//  EmarsysMobileShopSwift
//
//

import UIKit
import EmarsysMobile

class CategoryViewController: UIViewController, UITabBarDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var recommendedCollectionView: UICollectionView!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var categorySearchBar: UISearchBar!
    
    var category: String!
    var originalItems = [Item]()
    var searchResults = [Item]()
    var searchTerm: String = ""
    var recommendationManager = RecommendationManager()
    var itemsManager = ItemsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recommendationManager.recommendResults = [Item]()
        categoryTableView.dataSource = itemsManager
        categoryTableView.delegate = itemsManager
        categorySearchBar.delegate = self
        recommendedCollectionView.dataSource = recommendationManager
        recommendedCollectionView.delegate = recommendationManager
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        title = category
        originalItems = DataSource.sharedDataSource.itemsFromCategory(category)
        itemsManager.items = searchTerm.isEmpty ? originalItems : searchResults
        sendRecommend()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowItem" {
            let ctr = segue.destinationViewController as! ItemDetailViewController
            ctr.item = itemsManager.items[categoryTableView.indexPathForSelectedRow!.row]
        } else if segue.identifier == "ShowRecommendedItem" {
            let ctr = segue.destinationViewController as! ItemDetailViewController
            let recommendedItem = sender as! RecommendedItem
            ctr.item = recommendedItem.item
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchBar.resignFirstResponder()
            searchTerm.removeAll()
            searchResults.removeAll()
            itemsManager.items = originalItems
        } else {
            searchResults = originalItems.filter() {
                if let title = ($0 as Item).title {
                    return title.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
                } else {
                    return false
                }
            }
            itemsManager.items = searchResults
            searchTerm = searchText
        }
        categoryTableView.reloadData()
        sendRecommend()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            searchBar.resignFirstResponder()
            return false
        }
        return true
    }
    
    func sendRecommend() {
        let emarsysSession = EMSession.sharedSession()
        let transaction = EMTransaction()
        let cartItems = Cart.sharedCart.convertItems()
        transaction.setCart(cartItems)
        
        if !searchTerm.isEmpty {
            transaction.setSearchTerm(searchTerm)
        }
        
        recommendationManager.recommendResults.removeAll()
        
        let logic: String
        var exludeItems: [String] = [String]()
        
        if searchResults.count > 0 {
            let firstItem = searchResults[0]
            transaction.setView(firstItem.itemID)
            
            if searchResults.count > 1 {
                for item in searchResults {
                    exludeItems.append(item.itemID)
                }
            }
            logic = "RELATED"
            
        } else {
            transaction.setCategory(category)
            logic = "CATEGORY"
        }
        
        let recommend = EMRecommendationRequest(logic: logic)
        
        if exludeItems.count > 0 {
            recommend.excludeItemsWhere("item", isIn: exludeItems)
        }
        
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
        emarsysSession.sendTransaction(transaction, errorHandler: {error in
            // Some error happened
            NSLog("value: %@", error)
            return
        })
    }
}
