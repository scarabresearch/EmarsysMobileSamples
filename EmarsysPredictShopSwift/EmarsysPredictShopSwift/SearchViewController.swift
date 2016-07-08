//
//  SearchViewController.swift
//  EmarsysPredictShopSwift
//
//

import UIKit
import EmarsysPredictSDK

class SearchViewController: UIViewController, UITabBarDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var recommendedCollectionView: UICollectionView!
    @IBOutlet weak var itemSearchBar: UISearchBar!
    
    var searchTerm: String = ""
    var recommendationManager = RecommendationManager()
    var itemsManager = ItemsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemsTableView.dataSource = itemsManager
        itemsTableView.delegate = itemsManager
        itemsManager.items = DataSource.sharedDataSource.items
        itemSearchBar.delegate = self
        recommendedCollectionView.dataSource = recommendationManager
        recommendedCollectionView.delegate = recommendationManager
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        sendRecommend()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowItem" {
            let ctr = segue.destinationViewController as! ItemDetailViewController
            ctr.item = itemsManager.items[itemsTableView.indexPathForSelectedRow!.row]
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
            itemsManager.items = DataSource.sharedDataSource.items
        } else {
            itemsManager.items = DataSource.sharedDataSource.items.filter() {
                if let title = ($0 as Item).title {
                    return title.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
                } else {
                    return false
                }
            }
            searchTerm = searchText
        }
        itemsTableView.reloadData()
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
        recommendationManager.recommendResults.removeAll()
        self.recommendedCollectionView.reloadData()
        
        let emarsysSession = EMSession.sharedSession()
        let transaction = EMTransaction()
        let cartItems = Cart.sharedCart.convertItems()
        transaction.setCart(cartItems)
        
        if !searchTerm.isEmpty {
            transaction.setSearchTerm(searchTerm)
        }

        
        let recommend = EMRecommendationRequest(logic: "PERSONAL")
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
