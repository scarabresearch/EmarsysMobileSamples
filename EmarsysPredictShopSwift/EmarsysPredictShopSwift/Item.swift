//
//  Item.swift
//  EmarsysPredictShopSwift
//
//

import Foundation
import EmarsysPredictSDK

class Item: NSObject {
    var itemID: String = ""
    var link: String? = nil
    var title: String? = nil
    var image: String? = nil
    var category: String? = nil
    var price: float_t? = nil
    var available: Bool? = nil
    var brand: String? = nil
    var srcItem: EMRecommendationItem? = nil
    
    override init() {
        super.init()
    }
    
    init(withItem item: EMRecommendationItem) {
        super.init()
        srcItem = item
        itemID = item.data["item"]! as! String
        link = item.data["link"] as? String
        title = item.data["title"] as? String
        image = item.data["image"] as? String
        category = item.data["category"] as? String
        price = item.data["price"] as? float_t
        available = item.data["available"] as? Bool
        brand = item.data["brand"] as? String
    }
}
